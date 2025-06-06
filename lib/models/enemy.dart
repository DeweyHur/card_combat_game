import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/base_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_combat_app/models/name_emoji_interface.dart';

// Static data loaded from CSV
class EnemyTemplate extends StaticDataModel {
  static List<EnemyTemplate>? _templates;
  static List<EnemyTemplate> get templates => _templates ?? [];

  final String name;
  final int maxHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  final String imagePath;
  final String soundPath;
  final String description;
  final String special;

  EnemyTemplate({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.soundPath,
    required this.description,
    required this.special,
  });

  factory EnemyTemplate.fromCsvRow(List<dynamic> row) {
    return EnemyTemplate(
      name: row[0] as String,
      maxHealth: int.parse(row[1].toString()),
      attack: int.parse(row[2].toString()),
      defense: int.parse(row[3].toString()),
      emoji: row[4] as String,
      color: row[5] as String,
      imagePath: row[6] as String,
      soundPath: row[7] as String,
      description: row[8] as String,
      special: row[9].toString(),
    );
  }

  static Future<List<EnemyTemplate>> loadFromCsv(String assetPath) async {
    final rows = await StaticDataModel.loadCsvData(assetPath);
    _templates = rows.map((row) => EnemyTemplate.fromCsvRow(row)).toList();
    return _templates!;
  }

  static EnemyTemplate? findByName(String name) {
    return StaticDataModel.find<EnemyTemplate>(_templates, 'name', name);
  }

  static EnemyTemplate? findBySpecial(String special) {
    return StaticDataModel.find<EnemyTemplate>(_templates, 'special', special);
  }
}

// Active enemy state during a run
class EnemyRun extends GameCharacter
    implements RunDataModel, NameEmojiInterface {
  final EnemyTemplate template;
  final Map<StatusEffect, int> statusEffects = {};

  EnemyRun(this.template) : super(maxHealth: template.maxHealth);

  @override
  String get name => template.name;

  @override
  String get emoji => template.emoji;

  void addStatus(StatusEffect status) {
    final currentCount = statusEffects[status] ?? 0;
    statusEffects[status] = currentCount + 1;
    notifyListeners();
  }

  void removeStatus(StatusEffect status) {
    statusEffects.remove(status);
    notifyListeners();
  }

  bool hasStatus(StatusEffect status) {
    return statusEffects.containsKey(status) && statusEffects[status]! > 0;
  }

  void clearStatusEffects() {
    statusEffects.clear();
    notifyListeners();
  }

  void startTurn() {
    GameLogger.info(LogCategory.combat, '$name starts turn');
  }

  @override
  void reset() {
    currentHealth = maxHealth;
    statusEffects.clear();
    notifyListeners();
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': template.name,
        'maxHealth': maxHealth,
        'attack': template.attack,
        'defense': template.defense,
        'emoji': template.emoji,
        'color': template.color,
        'imagePath': template.imagePath,
        'soundPath': template.soundPath,
        'description': template.description,
        'currentHealth': currentHealth,
        'statusEffects': statusEffects.entries
            .map((e) => {
                  'type': e.key.toString().split('.').last,
                  'count': e.value,
                })
            .toList(),
      };

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('enemyRun:${template.name}', jsonEncode(toJson()));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('enemyRun:${template.name}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        currentHealth = data['currentHealth'] as int;

        // Load status effects
        statusEffects.clear();
        final effects = data['statusEffects'] as List<dynamic>;
        for (final effect in effects) {
          final type = StatusEffect.values.firstWhere(
            (e) => e.toString().split('.').last == effect['type'],
            orElse: () => StatusEffect.none,
          );
          if (type != StatusEffect.none) {
            statusEffects[type] = effect['count'] as int;
          }
        }

        notifyListeners();
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading enemy run data: $e');
      }
    }
  }
}
