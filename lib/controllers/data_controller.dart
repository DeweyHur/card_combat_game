import 'dart:async';
import 'package:card_combat_app/utils/game_logger.dart';

class DataController {
  static final DataController instance = DataController._internal();
  final Map<String, dynamic> _data = {};
  final Map<String, List<Function(dynamic)>> _watchers = {};
  final Map<String, StreamController<dynamic>> _streamControllers = {};
  final Map<String, Map<String, dynamic>> _sceneData = {};

  DataController._internal();

  // Get all keys in the data store
  Set<String> get keys => _data.keys.toSet();

  // Get value for a key, supporting nested paths
  T? get<T>(String key) {
    final parts = key.split('.');
    dynamic current = _data;

    for (final part in parts) {
      if (current is! Map) return null;
      current = current[part];
      if (current == null) return null;
    }

    return current as T?;
  }

  // Get scene-specific value
  T? getSceneData<T>(String sceneName, String key) {
    final sceneData = _sceneData[sceneName];
    if (sceneData == null) return null;
    return sceneData[key] as T?;
  }

  // Set scene-specific value
  void setSceneData<T>(String sceneName, String key, T value) {
    if (!_sceneData.containsKey(sceneName)) {
      _sceneData[sceneName] = {};
      GameLogger.debug(
          LogCategory.data, 'Created new scene data map for: $sceneName');
    }
    _sceneData[sceneName]![key] = value;

    // Notify watchers for the full key (scene.key)
    final fullKey = '$sceneName.$key';
    if (_watchers.containsKey(fullKey)) {
      for (final watcher in _watchers[fullKey]!) {
        watcher(value);
      }
    }

    // Add to stream if it exists
    if (_streamControllers.containsKey(fullKey)) {
      _streamControllers[fullKey]!.add(value);
    }
  }

  // Set value for a key, supporting nested paths
  void set<T>(String key, T value) {
    final parts = key.split('.');
    if (parts.length == 1) {
      _data[key] = value;
      _notifyWatchers(key, value);
      return;
    }

    // Build nested structure
    Map<String, dynamic> current = _data;
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) {
        current[part] = <String, dynamic>{};
      }
      if (current[part] is! Map) {
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }

    final lastPart = parts.last;
    current[lastPart] = value;

    // Notify watchers for the full path and any matching wildcard patterns
    _notifyWatchers(key, value);
    _notifyWildcardWatchers(key, value);
  }

  void update<T>(String key, T value) {
    set(key, value);
  }

  // Watch a key for changes, supporting nested paths and wildcards
  void watch(String key, Function(dynamic) callback) {
    if (!_watchers.containsKey(key)) {
      _watchers[key] = [];
    }
    _watchers[key]!.add(callback);

    // Immediately call with current value if it exists
    final value = get(key);
    if (value != null) {
      callback(value);
    }
  }

  // Unwatch a key
  void unwatch(String key, Function(dynamic) callback) {
    if (_watchers.containsKey(key)) {
      _watchers[key]!.remove(callback);
      if (_watchers[key]!.isEmpty) {
        _watchers.remove(key);
      }
    }
  }

  // Notify watchers for a specific key
  void _notifyWatchers(String key, dynamic value) {
    if (_watchers.containsKey(key)) {
      for (final watcher in _watchers[key]!) {
        watcher(value);
      }
    }

    // Add to stream if it exists
    if (_streamControllers.containsKey(key)) {
      _streamControllers[key]!.add(value);
    }
  }

  // Notify watchers for wildcard patterns
  void _notifyWildcardWatchers(String key, dynamic value) {
    final parts = key.split('.');

    // Check all possible wildcard patterns
    for (int i = 0; i < parts.length; i++) {
      final wildcardKey = [...parts];
      wildcardKey[i] = '*';
      final pattern = wildcardKey.join('.');

      if (_watchers.containsKey(pattern)) {
        for (final watcher in _watchers[pattern]!) {
          watcher(value);
        }
      }
    }
  }

  // Get a stream for a key
  Stream<dynamic> watchStream(String key) {
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] = StreamController<dynamic>.broadcast();
      // Add current value to stream if it exists
      final value = get(key);
      if (value != null) {
        _streamControllers[key]!.add(value);
      }
    }
    return _streamControllers[key]!.stream;
  }

  // Check if a key exists
  bool has(String key) {
    return get(key) != null;
  }

  // Remove a key and its watchers
  void remove(String key) {
    final parts = key.split('.');
    if (parts.length == 1) {
      _data.remove(key);
      _watchers.remove(key);
      if (_streamControllers.containsKey(key)) {
        _streamControllers[key]!.close();
        _streamControllers.remove(key);
      }
      return;
    }

    // Remove nested value
    Map<String, dynamic> current = _data;
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) return;
      if (current[part] is! Map) return;
      current = current[part] as Map<String, dynamic>;
    }

    final lastPart = parts.last;
    current.remove(lastPart);

    // Clean up watchers and streams
    _watchers.remove(key);
    if (_streamControllers.containsKey(key)) {
      _streamControllers[key]!.close();
      _streamControllers.remove(key);
    }
  }

  // Clear all data and watchers
  void clear() {
    _data.clear();
    _watchers.clear();
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    GameLogger.debug(LogCategory.data, 'All data cleared');
  }

  // Dispose of the controller
  void dispose() {
    clear();
  }

  // Remove all data for a specific scene
  void removeSceneData(String sceneName) {
    _sceneData.remove(sceneName);
    GameLogger.debug(LogCategory.data, 'Removed scene data for: $sceneName');
  }
}
