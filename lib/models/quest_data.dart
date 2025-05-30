import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

class QuestData extends ChangeNotifier {
  final String title;
  final String description;
  final Player player;
  final List<String> rewards;
  final List<String> penalties;
  final List<String> requirements;
  final List<String> restrictions;
  final List<String> events;
  final List<QuestChoice> choices;
  final List<String> outcomes;
  final List<String> conditions;
  final List<String> actions;
  final List<String> triggers;
  final List<String> effects;
  final List<String> modifiers;
  final List<String> buffs;
  final List<String> debuffs;
  final List<String> statuses;
  final List<String> items;
  final List<String> equipment;
  final List<String> cards;
  final List<String> abilities;
  final List<String> skills;
  final List<String> traits;
  final List<String> perks;
  final List<String> flaws;
  final List<String> quests;
  final List<String> missions;
  final List<String> objectives;
  final List<String> goals;
  final List<String> tasks;
  final List<String> challenges;
  final List<String> obstacles;
  final List<String> enemies;
  final List<String> allies;
  final List<String> npcs;
  final List<String> locations;
  final List<String> areas;
  final List<String> zones;
  final List<String> regions;
  final List<String> worlds;
  final List<String> dimensions;
  final List<String> realms;
  final List<String> planes;
  final List<String> universes;
  final List<String> timelines;
  final List<String> realities;
  final List<String> possibilities;
  final List<String> consequences;
  final List<String> results;

  QuestData({
    required this.title,
    required this.description,
    required this.player,
    required this.rewards,
    required this.penalties,
    required this.requirements,
    required this.restrictions,
    required this.events,
    required this.choices,
    required this.outcomes,
    required this.conditions,
    required this.actions,
    required this.triggers,
    required this.effects,
    required this.modifiers,
    required this.buffs,
    required this.debuffs,
    required this.statuses,
    required this.items,
    required this.equipment,
    required this.cards,
    required this.abilities,
    required this.skills,
    required this.traits,
    required this.perks,
    required this.flaws,
    required this.quests,
    required this.missions,
    required this.objectives,
    required this.goals,
    required this.tasks,
    required this.challenges,
    required this.obstacles,
    required this.enemies,
    required this.allies,
    required this.npcs,
    required this.locations,
    required this.areas,
    required this.zones,
    required this.regions,
    required this.worlds,
    required this.dimensions,
    required this.realms,
    required this.planes,
    required this.universes,
    required this.timelines,
    required this.realities,
    required this.possibilities,
    required this.consequences,
    required this.results,
  });

  void addEquipment(String equipmentData) {
    try {
      final equipment = Equipment.fromString(equipmentData);
      player.addEquipment(equipment);
      notifyListeners();
    } catch (e) {
      GameLogger.error(LogCategory.model, 'Error adding equipment: $e');
    }
  }

  void restoreHealth(int amount) {
    player.restoreHealth(amount);
    notifyListeners();
  }

  void gainEnergy(int amount) {
    player.gainEnergy(amount);
    notifyListeners();
  }

  void drawCards(int amount) {
    player.drawCards(amount);
    notifyListeners();
  }

  void addStatus(String status) {
    player.addStatus(status);
    notifyListeners();
  }

  void removeStatus(String status) {
    player.removeStatus(status);
    notifyListeners();
  }

  void upgradeEquipment(String slot) {
    player.upgradeEquipment(slot);
    notifyListeners();
  }

  void loseEnergy(int amount) {
    player.loseEnergy(amount);
    notifyListeners();
  }

  void discardCards(int amount) {
    player.discardCards(amount);
    notifyListeners();
  }

  void downgradeEquipment(String slot) {
    player.downgradeEquipment(slot);
    notifyListeners();
  }

  static Future<List<QuestData>> loadQuests() async {
    final String rawData =
        await rootBundle.loadString('assets/data/quests.csv');
    final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

    // Skip header row
    final List<List<dynamic>> data = listData.skip(1).toList();

    // Group by title to combine choices for the same quest
    final Map<String, List<Map<String, dynamic>>> questMap = {};

    for (var row in data) {
      final title = row[0] as String;
      if (!questMap.containsKey(title)) {
        questMap[title] = [];
      }

      questMap[title]!.add({
        'description': row[1] as String,
        'choice_text': row[2] as String,
        'success_chance': double.parse(row[3] as String),
        'success_reward_type': row[4] as String,
        'success_reward_value': row[5] as String,
        'failure_penalty_type': row[6] as String,
        'failure_penalty_value': row[7] as String,
      });
    }

    return questMap.entries.map((entry) {
      final choices = entry.value.map((choiceData) {
        return QuestChoice(
          text: choiceData['choice_text'] as String,
          outcome: QuestOutcome(
            successChance: choiceData['success_chance'] as double,
            successReward: (player) => _applyReward(
              player,
              choiceData['success_reward_type'] as String,
              choiceData['success_reward_value'] as String,
            ),
            failurePenalty: (player) => _applyPenalty(
              player,
              choiceData['failure_penalty_type'] as String,
              choiceData['failure_penalty_value'] as String,
            ),
          ),
        );
      }).toList();

      // Create empty lists for all the required fields
      final emptyList = <String>[];

      return QuestData(
        title: entry.key,
        description: entry.value.first['description'] as String,
        player: Player(
          maxHealth: 100,
          attack: 10,
          defense: 5,
          emoji: '👤',
          color: 'blue',
          description: 'Default player',
          maxEnergy: 3,
          handSize: 5,
          special: 'None',
          baseDeck: emptyList,
          equipmentSlots: emptyList,
          startingEquipment: emptyList,
        ),
        rewards: emptyList,
        penalties: emptyList,
        requirements: emptyList,
        restrictions: emptyList,
        events: emptyList,
        choices: choices,
        outcomes: emptyList,
        conditions: emptyList,
        actions: emptyList,
        triggers: emptyList,
        effects: emptyList,
        modifiers: emptyList,
        buffs: emptyList,
        debuffs: emptyList,
        statuses: emptyList,
        items: emptyList,
        equipment: emptyList,
        cards: emptyList,
        abilities: emptyList,
        skills: emptyList,
        traits: emptyList,
        perks: emptyList,
        flaws: emptyList,
        quests: emptyList,
        missions: emptyList,
        objectives: emptyList,
        goals: emptyList,
        tasks: emptyList,
        challenges: emptyList,
        obstacles: emptyList,
        enemies: emptyList,
        allies: emptyList,
        npcs: emptyList,
        locations: emptyList,
        areas: emptyList,
        zones: emptyList,
        regions: emptyList,
        worlds: emptyList,
        dimensions: emptyList,
        realms: emptyList,
        planes: emptyList,
        universes: emptyList,
        timelines: emptyList,
        realities: emptyList,
        possibilities: emptyList,
        consequences: emptyList,
        results: emptyList,
      );
    }).toList();
  }

  static String _applyReward(Player player, String type, String value) {
    switch (type) {
      case 'add_equipment':
        try {
          final equipment = Equipment.fromString(value);
          player.addEquipment(equipment);
          return 'You found a new piece of equipment: ${equipment.name}!';
        } catch (e) {
          debugPrint('Error adding equipment: $e');
          return 'Failed to add equipment.';
        }
      case 'restore_health':
        final amount = int.parse(value);
        player.restoreHealth(amount);
        return 'You restored $amount health!';
      case 'gain_energy':
        final amount = int.parse(value);
        player.gainEnergy(amount);
        return 'You gained $amount energy!';
      case 'draw_cards':
        final amount = int.parse(value);
        player.drawCards(amount);
        return 'You drew $amount cards!';
      case 'add_status':
        player.addStatus(value);
        return 'You gained $value status!';
      case 'remove_status':
        player.removeStatus(value);
        return 'You removed $value status!';
      case 'upgrade_equipment':
        player.upgradeEquipment(value);
        return 'You upgraded $value!';
      case 'message':
        return value;
      default:
        debugPrint('Unknown reward type: $type');
        return 'Something happened...';
    }
  }

  static String _applyPenalty(Player player, String type, String value) {
    switch (type) {
      case 'take_damage':
        final amount = int.parse(value);
        player.takeDamage(amount);
        return 'You took $amount damage!';
      case 'lose_energy':
        final amount = int.parse(value);
        player.loseEnergy(amount);
        return 'You lost $amount energy!';
      case 'discard_cards':
        final amount = int.parse(value);
        player.discardCards(amount);
        return 'You discarded $amount cards!';
      case 'add_status':
        player.addStatus(value);
        return 'You gained $value status!';
      case 'remove_status':
        player.removeStatus(value);
        return 'You lost $value status!';
      case 'downgrade_equipment':
        player.downgradeEquipment(value);
        return 'You downgraded $value!';
      case 'message':
        return value;
      default:
        debugPrint('Unknown penalty type: $type');
        return 'Something happened...';
    }
  }

  static Future<QuestData> loadFromCSV(String title) async {
    final String rawData =
        await rootBundle.loadString('assets/data/quests.csv');
    final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

    // Skip header row
    final List<List<dynamic>> data = listData.skip(1).toList();

    for (var row in data) {
      if (row[0].toString() == title) {
        return QuestData(
          title: row[0].toString(),
          description: row[1].toString(),
          player: row[2] as Player,
          rewards: row[3] as List<String>,
          penalties: row[4] as List<String>,
          requirements: row[5] as List<String>,
          restrictions: row[6] as List<String>,
          events: row[7] as List<String>,
          choices: [],
          outcomes: row[8] as List<String>,
          conditions: row[9] as List<String>,
          actions: row[10] as List<String>,
          triggers: row[11] as List<String>,
          effects: row[12] as List<String>,
          modifiers: row[13] as List<String>,
          buffs: row[14] as List<String>,
          debuffs: row[15] as List<String>,
          statuses: row[16] as List<String>,
          items: row[17] as List<String>,
          equipment: row[18] as List<String>,
          cards: row[19] as List<String>,
          abilities: row[20] as List<String>,
          skills: row[21] as List<String>,
          traits: row[22] as List<String>,
          perks: row[23] as List<String>,
          flaws: row[24] as List<String>,
          quests: row[25] as List<String>,
          missions: row[26] as List<String>,
          objectives: row[27] as List<String>,
          goals: row[28] as List<String>,
          tasks: row[29] as List<String>,
          challenges: row[30] as List<String>,
          obstacles: row[31] as List<String>,
          enemies: row[32] as List<String>,
          allies: row[33] as List<String>,
          npcs: row[34] as List<String>,
          locations: row[35] as List<String>,
          areas: row[36] as List<String>,
          zones: row[37] as List<String>,
          regions: row[38] as List<String>,
          worlds: row[39] as List<String>,
          dimensions: row[40] as List<String>,
          realms: row[41] as List<String>,
          planes: row[42] as List<String>,
          universes: row[43] as List<String>,
          timelines: row[44] as List<String>,
          realities: row[45] as List<String>,
          possibilities: row[46] as List<String>,
          consequences: row[47] as List<String>,
          results: row[48] as List<String>,
        );
      }
    }

    throw Exception('Quest not found: $title');
  }
}

class QuestChoice {
  final String text;
  final QuestOutcome outcome;

  QuestChoice({
    required this.text,
    required this.outcome,
  });
}

class QuestOutcome {
  final double successChance;
  final String Function(Player) successReward;
  final String Function(Player) failurePenalty;

  QuestOutcome({
    required this.successChance,
    required this.successReward,
    required this.failurePenalty,
  });
}
