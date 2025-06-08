import 'package:card_combat_app/utils/game_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'base_models.dart';
import 'game_character.dart'; // For StatusEffect

enum CardType {
  attack,
  heal,
  statusEffect,
  cure,
  shield, // Adds shield to the player
  shieldAttack, // Attacks using shield value
}

// Static data loaded from CSV
class CardTemplate extends StaticDataModel {
  static List<CardTemplate>? _templates;
  static List<CardTemplate> get templates => _templates ?? [];

  final String name;
  final String description;
  final String type;
  final int cost;
  final int damage;
  final int defense;
  final String effect;
  final String rarity;
  final String imagePath;

  CardTemplate({
    required this.name,
    required this.description,
    required this.type,
    required this.cost,
    required this.damage,
    required this.defense,
    required this.effect,
    required this.rarity,
    required this.imagePath,
  });

  factory CardTemplate.fromCsvRow(List<dynamic> row) {
    return CardTemplate(
      name: row[0] as String,
      description: row[1] as String,
      type: row[2] as String,
      cost: int.parse(row[3].toString()),
      damage: int.parse(row[4].toString()),
      defense: int.parse(row[5].toString()),
      effect: row[6] as String,
      rarity: row[7] as String,
      imagePath: row[8] as String,
    );
  }

  static Future<List<CardTemplate>> loadFromCsv(String assetPath) async {
    final rows = await StaticDataModel.loadCsvData(assetPath);
    GameLogger.debug(LogCategory.data, 'FULL CARD ROWS OBJECT:');
    GameLogger.debug(LogCategory.data, rows.toString());
    _templates = rows.map((row) => CardTemplate.fromCsvRow(row)).toList();
    return _templates!;
  }

  static CardTemplate? findByName(String name) {
    return StaticDataModel.find<CardTemplate>(_templates, 'name', name);
  }

  static List<CardTemplate> findByType(String type) {
    return _templates?.where((template) => template.type == type).toList() ??
        [];
  }

  static List<CardTemplate> findByRarity(String rarity) {
    return _templates
            ?.where((template) => template.rarity == rarity)
            .toList() ??
        [];
  }
}

// Local setup data for card configuration
class CardSetup extends LocalSetupModel {
  final CardTemplate template;
  int level;
  int _value;
  int _cost;

  CardSetup(this.template)
      : level = 1,
        _value = template.damage,
        _cost = template.cost;

  int get value => _value;
  int get cost => _cost;

  void upgrade() {
    level++;
    _value = (template.damage * (1 + (level - 1) * 0.5)).round();
    if (template.cost > 0) {
      _cost = (template.cost * (1 - (level - 1) * 0.2)).round().clamp(0, 3);
    }
    saveToLocalStorage();
  }

  @override
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'template': template.name,
      'level': level,
      'value': _value,
      'cost': _cost,
    };
    await prefs.setString('cardSetup:${template.name}', jsonEncode(data));
  }

  @override
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('cardSetup:${template.name}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        level = data['level'] as int;
        _value = data['value'] as int;
        _cost = data['cost'] as int;
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading saved data: $e');
      }
    }
  }
}

// Active card state during a run
class CardRun extends RunDataModel with ChangeNotifier {
  static Map<String, CardRun>? _allCards;
  static List<CardRun> get allCards => _allCards?.values.toList() ?? [];

  final CardSetup setup;
  bool isExhausted = false;
  bool isUpgraded = false;

  // Combat-related properties
  final CardType type;
  final StatusEffect? statusEffectToApply;
  final int? statusDuration;
  final String color;
  final String target; // 'player' or 'enemy' (or 'self')
  final int value;
  final int cost;
  final String name;
  final String description;
  final String rarity;
  final String imagePath;

  String get statusEffect =>
      statusEffectToApply?.toString().split('.').last.toLowerCase() ?? '';

  CardRun(this.setup)
      : type = _mapCardType(setup.template.type),
        statusEffectToApply = _mapStatusEffect(setup.template.effect),
        statusDuration = _parseStatusDuration(setup.template.effect),
        color = _determineCardColor(setup.template.rarity),
        target = _determineCardTarget(setup.template.type),
        value = setup.value,
        cost = setup.cost,
        name = setup.template.name,
        description = setup.template.description,
        rarity = setup.template.rarity,
        imagePath = setup.template.imagePath;

  void exhaust() {
    isExhausted = true;
    notifyListeners();
  }

  void refresh() {
    isExhausted = false;
    notifyListeners();
  }

  void upgrade() {
    isUpgraded = true;
    setup.upgrade();
    notifyListeners();
  }

  // Helper methods for mapping card properties
  static CardType _mapCardType(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return CardType.attack;
      case 'defense':
      case 'shield':
        return CardType.shield;
      case 'heal':
        return CardType.heal;
      case 'cure':
        return CardType.cure;
      case 'skill':
        return CardType.statusEffect;
      default:
        return CardType.attack;
    }
  }

  static StatusEffect? _mapStatusEffect(String effect) {
    if (effect.isEmpty) return null;
    try {
      return StatusEffect.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() == effect.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static int? _parseStatusDuration(String effect) {
    if (effect.isEmpty) return null;
    final durationMatch = RegExp(r'(\d+)\s*turns?').firstMatch(effect);
    if (durationMatch != null) {
      return int.tryParse(durationMatch.group(1) ?? '');
    }
    return null;
  }

  static String _determineCardColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'blue';
      case 'uncommon':
        return 'green';
      case 'rare':
        return 'purple';
      case 'epic':
        return 'orange';
      case 'legendary':
        return 'red';
      default:
        return 'blue';
    }
  }

  static String _determineCardTarget(String type) {
    switch (type.toLowerCase()) {
      case 'heal':
      case 'shield':
        return 'player';
      case 'cure':
        return 'self';
      default:
        return 'enemy';
    }
  }

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'setup': setup.template.name,
      'isExhausted': isExhausted,
      'isUpgraded': isUpgraded,
    };
    await prefs.setString('cardRun:${setup.template.name}', jsonEncode(data));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('cardRun:${setup.template.name}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        isExhausted = data['isExhausted'] as bool;
        isUpgraded = data['isUpgraded'] as bool;
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading saved data: $e');
      }
    }
  }

  // Static methods for loading cards
  static Future<void> loadLibrary(String assetPath) async {
    _allCards = await loadCardsByNameFromCsv(assetPath);
  }

  static CardRun? findByName(String name) {
    return _allCards != null ? _allCards![name] : null;
  }

  static Future<Map<String, List<CardRun>>> loadCardsByOwnerFromCsv(
      String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final rows = const CsvToListConverter().convert(csvString);
    final dataRows = rows.skip(1);
    final Map<String, List<CardRun>> ownerCards = {};
    final Map<String, CardRun> cardsByName = {};
    for (final row in dataRows) {
      try {
        if (row.length < 9) {
          GameLogger.warning(
              LogCategory.data, 'Skipping malformed card row: $row');
          continue;
        }
        final owner = row[0] as String;
        final name = row[1] as String;
        final template = CardTemplate.findByName(name);
        if (template == null) {
          GameLogger.warning(
              LogCategory.data, 'Card template not found: $name');
          continue;
        }
        final card = CardRun(CardSetup(template));
        ownerCards.putIfAbsent(owner, () => []);
        ownerCards[owner]!.add(card);
        cardsByName[name] = card;
      } catch (e) {
        GameLogger.warning(
            LogCategory.data, 'Error parsing card row: $row, error: $e');
        continue;
      }
    }
    return ownerCards;
  }

  static Future<Map<String, CardRun>> loadCardsByNameFromCsv(
      String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final rows = const CsvToListConverter().convert(csvString);
    final dataRows = rows.skip(1);
    final Map<String, CardRun> cardsByName = {};
    for (final row in dataRows) {
      try {
        if (row.length < 9) {
          GameLogger.warning(
              LogCategory.data, 'Skipping malformed card row: $row');
          continue;
        }
        final name = row[1] as String;
        final template = CardTemplate.findByName(name);
        if (template == null) {
          GameLogger.warning(
              LogCategory.data, 'Card template not found: $name');
          continue;
        }
        final card = CardRun(CardSetup(template));
        cardsByName[name] = card;
      } catch (e) {
        GameLogger.warning(
            LogCategory.data, 'Error parsing card row: $row, error: $e');
        continue;
      }
    }
    return cardsByName;
  }
}
