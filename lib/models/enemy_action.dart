import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class EnemyActionTemplate {
  final String actionName;
  final String description;
  final String type;
  final int value;
  final double probability;
  final String statusEffect;
  final int statusDuration;

  EnemyActionTemplate({
    required this.actionName,
    required this.description,
    required this.type,
    required this.value,
    required this.probability,
    required this.statusEffect,
    required this.statusDuration,
  });

  static List<EnemyActionTemplate> _templates = [];

  static Future<void> loadFromCsv(String path) async {
    try {
      final String data = await rootBundle.loadString(path);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(data);
      _templates = [];

      // Skip header row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 7) {
          try {
            final template = EnemyActionTemplate(
              actionName: row[0].toString(),
              description: row[1].toString(),
              type: row[2].toString(),
              value: int.tryParse(row[3].toString()) ?? 0,
              probability: double.tryParse(row[4].toString()) ?? 0.0,
              statusEffect: row[5].toString(),
              statusDuration: int.tryParse(row[6].toString()) ?? 0,
            );
            _templates.add(template);
          } catch (e) {
            GameLogger.warning(
                LogCategory.data, 'Skipping malformed row $i: $e');
          }
        }
      }
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error loading enemy actions: $e');
    }
  }

  static EnemyActionTemplate? findByName(String name) {
    return _templates.firstWhere(
      (template) => template.actionName == name,
      orElse: () => throw Exception('Enemy action template not found: $name'),
    );
  }

  static List<EnemyActionTemplate> get templates =>
      List.unmodifiable(_templates);
}

class EnemyActionRun {
  final String actionName;
  final String description;
  final String type;
  final int value;
  final double probability;
  final String statusEffect;
  final int statusDuration;
  final String owner;
  bool isExhausted = false;
  bool isUpgraded = false;

  EnemyActionRun({
    required this.actionName,
    required this.description,
    required this.type,
    required this.value,
    required this.probability,
    required this.statusEffect,
    required this.statusDuration,
    required this.owner,
  });

  factory EnemyActionRun.fromTemplate(
      EnemyActionTemplate template, String owner) {
    return EnemyActionRun(
      actionName: template.actionName,
      description: template.description,
      type: template.type,
      value: template.value,
      probability: template.probability,
      statusEffect: template.statusEffect,
      statusDuration: template.statusDuration,
      owner: owner,
    );
  }

  CardRun? toCardRun() {
    try {
      // Create a CardSetup from the enemy action
      final setup = CardSetup(
        CardTemplate(
          name: actionName,
          description: description,
          type: type,
          cost: 0,
          damage: value,
          defense: 0,
          effect: statusEffect,
          rarity: 'common',
          imagePath:
              'assets/images/cards/enemy_${actionName.toLowerCase()}.png',
        ),
      );

      // Create and return the CardRun
      return CardRun(setup);
    } catch (e) {
      GameLogger.error(
          LogCategory.data, 'Error converting enemy action to card: $e');
      return null;
    }
  }

  CardType _mapTypeToCardType(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return CardType.attack;
      case 'heal':
        return CardType.heal;
      case 'statuseffect':
        return CardType.statusEffect;
      case 'cure':
        return CardType.cure;
      case 'shield':
        return CardType.shield;
      case 'shieldattack':
        return CardType.shieldAttack;
      default:
        throw Exception('Unknown card type: $type');
    }
  }
}
