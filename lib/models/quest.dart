import 'package:card_combat_app/models/base_models.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Static data loaded from CSV
class QuestTemplate extends StaticDataModel {
  static List<QuestTemplate>? _templates;
  static List<QuestTemplate> get templates => _templates ?? [];

  final String id;
  final String name;
  final String description;
  final String successText;
  final String failureText;
  final String successRewardType;
  final String successRewardValue;
  final String failureRewardType;
  final String failureRewardValue;
  final String enemyName;
  final int enemyLevel;
  final int enemyHealth;
  final int enemyAttack;
  final int enemyDefense;
  final String enemyEmoji;
  final String enemyColor;
  final String enemyDescription;
  final String enemySpecial;
  final int enemyMaxEnergy;
  final int enemyHandSize;
  final List<String> enemyEquipmentSlots;
  final List<String> enemyStartingEquipment;

  QuestTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.successText,
    required this.failureText,
    required this.successRewardType,
    required this.successRewardValue,
    required this.failureRewardType,
    required this.failureRewardValue,
    required this.enemyName,
    required this.enemyLevel,
    required this.enemyHealth,
    required this.enemyAttack,
    required this.enemyDefense,
    required this.enemyEmoji,
    required this.enemyColor,
    required this.enemyDescription,
    required this.enemySpecial,
    required this.enemyMaxEnergy,
    required this.enemyHandSize,
    required this.enemyEquipmentSlots,
    required this.enemyStartingEquipment,
  });

  factory QuestTemplate.fromCsvRow(List<dynamic> row) {
    final equipmentSlots = row[21].toString().split('|');
    final startingEquipment = row[22].toString().split('|');

    return QuestTemplate(
      id: row[0].toString(),
      name: row[1].toString(),
      description: row[2].toString(),
      successText: row[3].toString(),
      failureText: row[4].toString(),
      successRewardType: row[5].toString().toLowerCase(),
      successRewardValue: row[6].toString(),
      failureRewardType: row[7].toString().toLowerCase(),
      failureRewardValue: row[8].toString(),
      enemyName: row[9].toString(),
      enemyLevel: int.tryParse(row[10].toString()) ?? 1,
      enemyHealth: int.tryParse(row[11].toString()) ?? 100,
      enemyAttack: int.tryParse(row[12].toString()) ?? 10,
      enemyDefense: int.tryParse(row[13].toString()) ?? 5,
      enemyEmoji: row[14].toString(),
      enemyColor: row[15].toString(),
      enemyDescription: row[16].toString(),
      enemySpecial: row[17].toString(),
      enemyMaxEnergy: int.tryParse(row[18].toString()) ?? 3,
      enemyHandSize: int.tryParse(row[19].toString()) ?? 5,
      enemyEquipmentSlots: equipmentSlots,
      enemyStartingEquipment: startingEquipment,
    );
  }

  static Future<List<QuestTemplate>> loadFromCsv(String assetPath) async {
    final rows = await StaticDataModel.loadCsvData(assetPath);
    _templates = rows.map((row) => QuestTemplate.fromCsvRow(row)).toList();
    return _templates!;
  }

  static QuestTemplate? findById(String id) {
    return StaticDataModel.find<QuestTemplate>(_templates, 'id', id);
  }

  static List<QuestTemplate> findByEnemyName(String enemyName) {
    return _templates
            ?.where((template) => template.enemyName == enemyName)
            .toList() ??
        [];
  }
}

// Local setup data for quest configuration
class QuestSetup extends LocalSetupModel {
  final QuestTemplate template;
  final List<QuestChoice> choices;
  bool isCompleted = false;
  bool isFailed = false;

  QuestSetup(this.template) : choices = [];

  void addChoice(QuestChoice choice) {
    choices.add(choice);
    saveToLocalStorage();
  }

  void complete() {
    isCompleted = true;
    isFailed = false;
    saveToLocalStorage();
  }

  void fail() {
    isCompleted = false;
    isFailed = true;
    saveToLocalStorage();
  }

  @override
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'choices': choices.map((c) => c.toJson()).toList(),
      'isCompleted': isCompleted,
      'isFailed': isFailed,
    };
    await prefs.setString('questSetup:${template.id}', jsonEncode(data));
  }

  @override
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('questSetup:${template.id}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        choices.clear();
        for (final choiceData in data['choices'] as List) {
          choices.add(QuestChoice.fromJson(choiceData));
        }
        isCompleted = data['isCompleted'] as bool;
        isFailed = data['isFailed'] as bool;
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading saved data: $e');
      }
    }
  }
}

// Active quest state during a run
class QuestRun extends RunDataModel with ChangeNotifier {
  final QuestSetup setup;
  final PlayerRun player;
  bool isActive = false;
  String currentOutcome = '';

  QuestRun(this.setup, this.player);

  void start() {
    isActive = true;
    notifyListeners();
  }

  void end() {
    isActive = false;
    notifyListeners();
  }

  void applyReward() {
    if (setup.isCompleted) {
      switch (setup.template.successRewardType) {
        case 'equipment':
          final eq =
              EquipmentTemplate.findByName(setup.template.successRewardValue);
          if (eq != null) {
            player.equip(eq.type, eq);
          }
          break;
        case 'health':
          final amount = int.tryParse(setup.template.successRewardValue) ?? 0;
          player.heal(amount);
          break;
        case 'status':
          try {
            final statusEffect = StatusEffect.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  setup.template.successRewardValue,
            );
            player.addStatusEffect(
                statusEffect, 1); // Default duration of 1 turn
          } catch (e) {
            GameLogger.warning(LogCategory.data,
                'Unknown status effect: ${setup.template.successRewardValue}');
          }
          break;
      }
    } else if (setup.isFailed) {
      switch (setup.template.failureRewardType) {
        case 'equipment':
          final eq =
              EquipmentTemplate.findByName(setup.template.failureRewardValue);
          if (eq != null) {
            player.unequip(eq.type);
          }
          break;
        case 'health':
          final amount = int.tryParse(setup.template.failureRewardValue) ?? 0;
          player.takeDamage(amount);
          break;
        case 'status':
          try {
            final statusEffect = StatusEffect.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  setup.template.failureRewardValue,
            );
            player.addStatusEffect(
                statusEffect, 1); // Default duration of 1 turn
          } catch (e) {
            GameLogger.warning(LogCategory.data,
                'Unknown status effect: ${setup.template.failureRewardValue}');
          }
          break;
      }
    }
    notifyListeners();
  }

  @override
  void reset() {
    isActive = false;
    currentOutcome = '';
    notifyListeners();
  }

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'isActive': isActive,
      'currentOutcome': currentOutcome,
    };
    await prefs.setString('questRun:${setup.template.id}', jsonEncode(data));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('questRun:${setup.template.id}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        isActive = data['isActive'] as bool;
        currentOutcome = data['currentOutcome'] as String;
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading saved data: $e');
      }
    }
  }
}

class QuestChoice {
  final String text;
  final QuestOutcome outcome;

  QuestChoice({
    required this.text,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'outcome': outcome.toJson(),
      };

  factory QuestChoice.fromJson(Map<String, dynamic> json) {
    return QuestChoice(
      text: json['text'] as String,
      outcome: QuestOutcome.fromJson(json['outcome'] as Map<String, dynamic>),
    );
  }
}

class QuestOutcome {
  final double successChance;
  final String Function(PlayerRun) successReward;
  final String Function(PlayerRun) failurePenalty;

  QuestOutcome({
    required this.successChance,
    required this.successReward,
    required this.failurePenalty,
  });

  Map<String, dynamic> toJson() => {
        'successChance': successChance,
        'successReward': successReward.toString(),
        'failurePenalty': failurePenalty.toString(),
      };

  factory QuestOutcome.fromJson(Map<String, dynamic> json) {
    return QuestOutcome(
      successChance: json['successChance'] as double,
      successReward: (player) => json['successReward'] as String,
      failurePenalty: (player) => json['failurePenalty'] as String,
    );
  }
}
