import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/models/base_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Static data loaded from CSV
class QuestTemplate {
  static List<QuestTemplate>? _templates;
  static List<QuestTemplate> get templates => _templates ?? [];

  final String title;
  final String description;
  final List<QuestChoice> choices;

  QuestTemplate({
    required this.title,
    required this.description,
    required this.choices,
  });

  factory QuestTemplate.fromCsvRow(List<dynamic> row) {
    try {
      return QuestTemplate(
        title: row[0].toString(),
        description: row[1].toString(),
        choices: [
          QuestChoice(
            text: row[2].toString(),
            successChance: double.parse(row[3].toString()),
            successRewardType: row[4].toString(),
            successRewardValue: row[5].toString(),
            failurePenaltyType: row[6].toString(),
            failurePenaltyValue: row[7].toString(),
          ),
        ],
      );
    } catch (e) {
      GameLogger.error(
          LogCategory.data, 'Error parsing quest template from CSV row: $e');
      rethrow;
    }
  }

  static Future<List<QuestTemplate>> loadFromCsv(String assetPath) async {
    try {
      final rawData = await rootBundle.loadString(assetPath);
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(rawData);
      final dataRows = rows.skip(1); // Skip header row

      // Group rows by title to combine choices for the same quest
      final Map<String, List<QuestChoice>> questChoices = {};
      for (var row in dataRows) {
        final title = row[0].toString();
        if (!questChoices.containsKey(title)) {
          questChoices[title] = [];
        }
        questChoices[title]!.add(
          QuestChoice(
            text: row[2].toString(),
            successChance: double.parse(row[3].toString()),
            successRewardType: row[4].toString(),
            successRewardValue: row[5].toString(),
            failurePenaltyType: row[6].toString(),
            failurePenaltyValue: row[7].toString(),
          ),
        );
      }

      // Create QuestTemplate instances with grouped choices
      _templates = questChoices.entries.map((entry) {
        return QuestTemplate(
          title: entry.key,
          description: dataRows
              .firstWhere((row) => row[0].toString() == entry.key)[1]
              .toString(),
          choices: entry.value,
        );
      }).toList();

      return _templates!;
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error loading quest data: $e');
      rethrow;
    }
  }

  static QuestTemplate? findByTitle(String title) {
    if (_templates == null) return null;
    try {
      return _templates!.firstWhere(
        (template) => template.title == title,
        orElse: () => throw Exception('Quest not found: $title'),
      );
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error finding quest: $e');
      return null;
    }
  }
}

// Quest setup for a player
class QuestSetup extends LocalSetupModel {
  final Map<String, QuestTemplate> _activeQuests = {};
  final List<String> _completedQuests = [];

  Map<String, QuestTemplate> get activeQuests =>
      Map.unmodifiable(_activeQuests);
  List<String> get completedQuests => List.unmodifiable(_completedQuests);

  void startQuest(QuestTemplate quest) {
    if (_activeQuests.containsKey(quest.title)) {
      GameLogger.error(
          LogCategory.game, 'Quest already active: ${quest.title}');
      return;
    }
    _activeQuests[quest.title] = quest;
  }

  void completeQuest(String questTitle) {
    final quest = _activeQuests.remove(questTitle);
    if (quest != null) {
      _completedQuests.add(questTitle);
    }
  }

  bool isQuestActive(String questTitle) {
    return _activeQuests.containsKey(questTitle);
  }

  bool isQuestCompleted(String questTitle) {
    return _completedQuests.contains(questTitle);
  }

  @override
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'activeQuests': _activeQuests.keys.toList(),
      'completedQuests': _completedQuests,
    };
    await prefs.setString('questSetup', jsonEncode(data));
  }

  @override
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('questSetup');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        _activeQuests.clear();
        final activeQuests = data['activeQuests'] as List<dynamic>;
        for (final title in activeQuests) {
          final quest = QuestTemplate.findByTitle(title as String);
          if (quest != null) {
            _activeQuests[title] = quest;
          }
        }
        _completedQuests.clear();
        _completedQuests.addAll(
          (data['completedQuests'] as List<dynamic>).map((e) => e as String),
        );
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading quest setup: $e');
      }
    }
  }
}

// Active quest state during a run
class QuestRun extends RunDataModel {
  final QuestSetup setup;
  final QuestTemplate template;
  final Map<String, dynamic> _questState = {};
  final List<String> _completedChoices = [];
  final List<String> _activeEffects = [];

  Map<String, dynamic> get questState => Map.unmodifiable(_questState);
  List<String> get completedChoices => List.unmodifiable(_completedChoices);
  List<String> get activeEffects => List.unmodifiable(_activeEffects);

  QuestRun(this.setup, this.template);

  void updateQuestState(String key, dynamic value) {
    _questState[key] = value;
  }

  void completeChoice(String choiceText) {
    if (!_completedChoices.contains(choiceText)) {
      _completedChoices.add(choiceText);
    }
  }

  void addEffect(String effect) {
    if (!_activeEffects.contains(effect)) {
      _activeEffects.add(effect);
    }
  }

  void removeEffect(String effect) {
    _activeEffects.remove(effect);
  }

  bool isChoiceCompleted(String choiceText) {
    return _completedChoices.contains(choiceText);
  }

  bool hasEffect(String effect) {
    return _activeEffects.contains(effect);
  }

  @override
  Map<String, dynamic> toJson() => {
        'questTitle': template.title,
        'questState': _questState,
        'completedChoices': _completedChoices,
        'activeEffects': _activeEffects,
      };

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('questRun:${template.title}', jsonEncode(toJson()));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('questRun:${template.title}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        _questState.clear();
        _questState.addAll(data['questState'] as Map<String, dynamic>);
        _completedChoices.clear();
        _completedChoices.addAll(
          (data['completedChoices'] as List<dynamic>).map((e) => e as String),
        );
        _activeEffects.clear();
        _activeEffects.addAll(
          (data['activeEffects'] as List<dynamic>).map((e) => e as String),
        );
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading quest run data: $e');
      }
    }
  }
}

class QuestChoice {
  final String text;
  final double successChance;
  final String successRewardType;
  final String successRewardValue;
  final String failurePenaltyType;
  final String failurePenaltyValue;

  QuestChoice({
    required this.text,
    required this.successChance,
    required this.successRewardType,
    required this.successRewardValue,
    required this.failurePenaltyType,
    required this.failurePenaltyValue,
  });
}
