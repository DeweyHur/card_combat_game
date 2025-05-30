import 'dart:async';
import 'dart:convert';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/card_loader.dart';

class DataController {
  static final DataController instance = DataController._internal();
  final Map<String, dynamic> _data = {};
  final Map<String, List<Function(dynamic)>> _watchers = {};
  final Map<String, StreamController<dynamic>> _streamControllers = {};

  DataController._internal();

  // Get value for a key
  T? get<T>(String key) => _data[key] as T?;

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

    String serialize(dynamic v) {
      if (v == null) return 'null';
      if (v is List) {
        return jsonEncode(v.map((e) {
          if (e is GameCharacter) return e.toJson();
          if (e is EquipmentData) return e.toJson();
          return e;
        }).toList());
      }
      if (v is Map) {
        return jsonEncode(v.map((key, value) {
          if (value is GameCharacter) return MapEntry(key, value.toJson());
          if (value is EquipmentData) return MapEntry(key, value.toJson());
          return MapEntry(key, value);
        }));
      }
      if (v is GameCharacter) return v.toJson().toString();
      if (v is EquipmentData) return v.toJson().toString();
      return v.toString();
    }

    GameLogger.debug(LogCategory.data,
        'Data updated: $key = ${serialize(value)} (was: ${serialize(oldValue)})');
  }

  void update<T>(String key, T value) {
    set(key, value);
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

  void updatePlayersCsvField(int rowIndex, int colIndex, dynamic value) {
    final playersCsv = get<List<List<dynamic>>>('playersCsv');
    if (playersCsv == null || rowIndex < 0 || rowIndex >= playersCsv.length) {
      return;
    }
    final oldValue = playersCsv[rowIndex][colIndex];
    playersCsv[rowIndex][colIndex] = value;
    set<List<List<dynamic>>>('playersCsv', playersCsv);
    GameLogger.debug(LogCategory.data,
        'playersCsv[[38;5;214m$rowIndex[0m][[38;5;214m$colIndex[0m] updated: $oldValue -> $value');
  }

  /// Get the players CSV data
  static Future<List<List<dynamic>>?> getPlayersCsv() async {
    return instance.get<List<List<dynamic>>>('playersCsv');
  }

  /// Get the equipment data
  static Future<Map<String, EquipmentData>?> getEquipmentData() async {
    return instance.get<Map<String, EquipmentData>>('equipmentData');
  }

  /// Get the card data
  static Future<CardLoaderResult?> getCardData() async {
    return instance.get<CardLoaderResult>('cardData');
  }

  /// Update the selected player
  static void updateSelectedPlayer(GameCharacter player) {
    instance.update('selectedPlayer', player);
  }
}
