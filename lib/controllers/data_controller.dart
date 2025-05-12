import 'dart:async';
import 'package:card_combat_app/utils/game_logger.dart';

class DataController {
  static final DataController instance = DataController._();
  DataController._();

  final Map<String, dynamic> _data = {};
  final Map<String, List<Function(dynamic)>> _watchers = {};
  final Map<String, StreamController<dynamic>> _streamControllers = {};

  // Get value for a key
  T? get<T>(String key) {
    return _data[key] as T?;
  }

  // Set value for a key and notify watchers
  void set<T>(String key, T value) {
    final oldValue = _data[key];
    _data[key] = value;
    
    // Notify watchers
    if (_watchers.containsKey(key)) {
      for (final watcher in _watchers[key]!) {
        watcher(value);
      }
    }

    // Add to stream if it exists
    if (_streamControllers.containsKey(key)) {
      _streamControllers[key]!.add(value);
    }

    GameLogger.debug(LogCategory.data, 'Data updated: $key = $value (was: $oldValue)');
  }

  // Watch a key for changes
  void watch(String key, Function(dynamic) callback) {
    if (!_watchers.containsKey(key)) {
      _watchers[key] = [];
    }
    _watchers[key]!.add(callback);
    
    // Immediately call with current value if it exists
    if (_data.containsKey(key)) {
      callback(_data[key]);
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

  // Get a stream for a key
  Stream<dynamic> watchStream(String key) {
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] = StreamController<dynamic>.broadcast();
      // Add current value to stream if it exists
      if (_data.containsKey(key)) {
        _streamControllers[key]!.add(_data[key]);
      }
    }
    return _streamControllers[key]!.stream;
  }

  // Check if a key exists
  bool has(String key) {
    return _data.containsKey(key);
  }

  // Remove a key and its watchers
  void remove(String key) {
    _data.remove(key);
    _watchers.remove(key);
    if (_streamControllers.containsKey(key)) {
      _streamControllers[key]!.close();
      _streamControllers.remove(key);
    }
    GameLogger.debug(LogCategory.data, 'Data removed: $key');
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
} 