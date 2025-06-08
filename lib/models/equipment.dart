import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_combat_app/models/base_models.dart';

/// Valid equipment slots as defined in the custom instructions
const validEquipmentSlots = {
  'Head',
  'Chest',
  'Belt',
  'Pants',
  'Shoes',
  'Weapon',
  'Offhand',
  'Accessory 1',
  'Accessory 2',
};

/// Valid equipment rarities
const validRarities = {
  'common',
  'rare',
  'epic',
  'legendary',
};

// Static data loaded from CSV
class EquipmentTemplate {
  static List<EquipmentTemplate>? _templates;
  static List<EquipmentTemplate> get templates => _templates ?? [];

  final String name;
  final String description;
  final String rarity;
  final String type;
  final List<String> cards;

  EquipmentTemplate({
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    required this.cards,
  });

  factory EquipmentTemplate.fromCsvRow(List<dynamic> row) {
    final cardsStr = row.length > 4 ? row[4] as String : '';
    final cardsList = cardsStr
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return EquipmentTemplate(
      name: (row[0] as String).trim(),
      description: (row[1] as String).trim(),
      rarity: (row[2] as String).trim(),
      type: (row[3] as String).trim(),
      cards: cardsList,
    );
  }

  factory EquipmentTemplate.fromJson(Map<String, dynamic> json) {
    final cardsStr = json['cards'] as String? ?? '';
    final cardsList = cardsStr
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return EquipmentTemplate(
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: json['rarity'] as String,
      type: json['type'] as String,
      cards: cardsList,
    );
  }

  static Future<List<EquipmentTemplate>> loadFromCsv() async {
    final rows = await StaticDataModel.loadCsvData('assets/data/equipment.csv');
    GameLogger.info(LogCategory.data,
        'EquipmentTemplate.loadFromCsv received ${rows.length} rows');
    final templates = <EquipmentTemplate>[];
    for (final row in rows) {
      GameLogger.info(LogCategory.data, 'Processing equipment row: ${row}');
      try {
        final template = EquipmentTemplate(
          name: row[0],
          description: row[1],
          rarity: row[2],
          type: row[3],
          cards: row[4].split('|'),
        );
        templates.add(template);
      } catch (e) {
        GameLogger.error(
            LogCategory.data, 'Error processing equipment row: ${e}');
      }
    }
    GameLogger.info(
        LogCategory.data, 'Loaded ${templates.length} equipment templates');
    return templates;
  }

  static EquipmentTemplate? findByName(String name) {
    if (_templates == null) return null;
    try {
      final normalizedName = name.trim();
      return _templates!.firstWhere(
        (template) => template.name.trim() == normalizedName,
        orElse: () => throw Exception('Equipment not found: $name'),
      );
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error finding equipment: $e');
      return null;
    }
  }

  static List<EquipmentTemplate> findByType(String type) {
    return _templates?.where((template) => template.type == type).toList() ??
        [];
  }

  static List<EquipmentTemplate> findByRarity(String rarity) {
    return _templates
            ?.where((template) => template.rarity == rarity)
            .toList() ??
        [];
  }
}

// Equipment setup for a player
class EquipmentSetup implements LocalSetupModel {
  final Map<String, EquipmentTemplate> _equipment = {};

  Map<String, EquipmentTemplate> get equipment => Map.unmodifiable(_equipment);

  void equip(String type, EquipmentTemplate item) {
    if (!validEquipmentSlots.contains(type)) {
      GameLogger.error(LogCategory.game, 'Invalid equipment type: $type');
      return;
    }
    _equipment[type] = item;
  }

  void unequip(String type) {
    _equipment.remove(type);
  }

  EquipmentTemplate? getEquipped(String type) {
    return _equipment[type];
  }

  bool isEquipped(String type) {
    return _equipment.containsKey(type);
  }

  @override
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final equipmentData = _equipment.map(
      (type, item) => MapEntry(type, item.name),
    );
    await prefs.setString('equipmentSetup', jsonEncode(equipmentData));
  }

  @override
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('equipmentSetup');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        _equipment.clear();
        data.forEach((type, name) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            _equipment[type] = item;
          }
        });
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading equipment setup: $e');
      }
    }
  }
}

// Active equipment state during a run
class EquipmentRun implements RunDataModel {
  final EquipmentSetup setup;
  final Map<String, EquipmentTemplate> _equipment = {};
  final List<EquipmentTemplate> _inventory = [];

  Map<String, EquipmentTemplate> get equipment => Map.unmodifiable(_equipment);
  List<EquipmentTemplate> get inventory => List.unmodifiable(_inventory);

  EquipmentRun(this.setup) {
    _equipment.addAll(setup.equipment);
  }

  void equip(String type, EquipmentTemplate item) {
    if (!validEquipmentSlots.contains(type)) {
      GameLogger.error(LogCategory.game, 'Invalid equipment type: $type');
      return;
    }
    if (!_inventory.contains(item)) {
      GameLogger.error(LogCategory.game, 'Item not in inventory');
      return;
    }
    // Unequip current item if any
    final currentItem = _equipment[type];
    if (currentItem != null) {
      _inventory.add(currentItem);
    }
    // Equip new item
    _equipment[type] = item;
    _inventory.remove(item);
  }

  void unequip(String type) {
    if (_equipment.containsKey(type)) {
      final item = _equipment[type]!;
      _equipment.remove(type);
      _inventory.add(item);
    }
  }

  bool addToInventory(EquipmentTemplate item) {
    _inventory.add(item);
    return true;
  }

  bool removeFromInventory(EquipmentTemplate item) {
    return _inventory.remove(item);
  }

  @override
  Map<String, dynamic> toJson() => {
        'equipment': _equipment.map((type, item) => MapEntry(type, item.name)),
        'inventory': _inventory.map((item) => item.name).toList(),
      };

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipmentRun', jsonEncode(toJson()));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('equipmentRun');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;

        // Load equipment
        _equipment.clear();
        final equipmentData = data['equipment'] as Map<String, dynamic>;
        equipmentData.forEach((type, name) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            _equipment[type] = item;
          }
        });

        // Load inventory
        _inventory.clear();
        final inventoryData = data['inventory'] as List<dynamic>;
        for (final name in inventoryData) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            _inventory.add(item);
          }
        }
      } catch (e) {
        GameLogger.error(
            LogCategory.data, 'Error loading equipment run data: $e');
      }
    }
  }
}

/// Loads equipment data from a CSV file
Future<Map<String, EquipmentTemplate>> loadEquipmentFromCsv(
    String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1); // Skip header row
  final Map<String, EquipmentTemplate> equipment = {};

  // Track unique types for logging
  final Set<String> uniqueTypes = {};

  for (final row in dataRows) {
    try {
      final item = EquipmentTemplate.fromCsvRow(row);
      uniqueTypes.add(item.type);

      GameLogger.info(
        LogCategory.game,
        '[EQUIP_LOADER] Loading equipment: ${item.name}, Type: ${item.type}',
      );

      equipment[item.name] = item;
    } catch (e) {
      GameLogger.error(
        LogCategory.game,
        '[EQUIP_LOADER] Failed to load equipment from row: $e',
      );
    }
  }

  // Log all unique types found
  GameLogger.info(
    LogCategory.game,
    '[EQUIP_LOADER] All unique equipment types found: ${uniqueTypes.join(", ")}',
  );

  return equipment;
}
