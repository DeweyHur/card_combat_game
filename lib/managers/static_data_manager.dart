import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/enemy.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

/// Manages the initialization of all static game data
class StaticDataManager {
  static Future<void> initialize() async {
    GameLogger.info(LogCategory.data, 'Initializing static data...');

    try {
      // Load all static data in parallel
      await CardRun.loadLibrary('assets/data/cards.csv');
      GameLogger.info(LogCategory.data,
          'Game cards loaded successfully: ${CardRun.allCards.length} cards');

      final equipment = await EquipmentTemplate.loadFromCsv();
      GameLogger.info(LogCategory.data,
          'Equipment data loaded successfully: ${equipment.length} items');

      // Store equipment data in DataController
      final equipmentMap =
          Map.fromEntries(equipment.map((e) => MapEntry(e.name, e)));
      DataController.instance.set('equipmentData', equipmentMap);

      await Future.wait([
        PlayerTemplate.loadFromCsv('assets/data/players.csv'),
        EnemyTemplate.loadFromCsv('assets/data/enemies.csv'),
      ]);

      GameLogger.info(LogCategory.data, 'Static data initialized successfully');
    } catch (e) {
      GameLogger.error(
          LogCategory.data, 'Failed to initialize static data: $e');
      rethrow;
    }
  }

  // Helper methods to find templates by name
  static PlayerTemplate? findPlayerTemplate(String name) {
    try {
      return PlayerTemplate.templates.firstWhere(
        (template) => template.name == name,
      );
    } catch (e) {
      return null;
    }
  }

  static EnemyTemplate? findEnemyTemplate(String name) {
    try {
      return EnemyTemplate.templates.firstWhere(
        (template) => template.name == name,
      );
    } catch (e) {
      return null;
    }
  }

  static EquipmentTemplate? findEquipmentTemplate(String name) {
    try {
      return EquipmentTemplate.templates.firstWhere(
        (template) => template.name == name,
      );
    } catch (e) {
      return null;
    }
  }

  static CardRun? findCardTemplate(String name) {
    return CardRun.findByName(name);
  }

  // Getters for templates
  static List<PlayerTemplate> get playerTemplates => PlayerTemplate.templates;
  static List<EnemyTemplate> get enemyTemplates => EnemyTemplate.templates;
  static List<EquipmentTemplate> get equipmentTemplates =>
      EquipmentTemplate.templates;
  static List<CardRun> get cardTemplates => CardRun.allCards;
}
