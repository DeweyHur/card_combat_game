import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'package:card_combat_app/utils/audio_config.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/models/game_character_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/enemy_action_loader.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CardCombatGame extends FlameGame with TapDetector, HasCollisionDetection {
  final SoundManager _soundManager = SoundManager();

  CardCombatGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame loading...');

    final prefs = await SharedPreferences.getInstance();
    List<GameCharacter> players = [];
    List<GameCharacter> enemies = [];
    String? selectedPlayerName;

    // Try to load players from local storage
    final playersJson = prefs.getString('players');
    if (playersJson != null) {
      final List<dynamic> decoded = jsonDecode(playersJson);
      players = decoded.map((e) => GameCharacter.fromJson(e)).toList();
    }
    // Try to load selected player from local storage
    selectedPlayerName = prefs.getString('selectedPlayerName');

    // If not found, load from CSV as before
    if (players.isEmpty) {
      final allCards = await loadAllGameCards();
      final equipmentData =
          await loadEquipmentFromCsv('assets/data/equipment.csv');
      final enemyActionsByName =
          await loadEnemyActionsFromCsv('assets/data/enemy_actions.csv');
      final Map<String, List<GameCard>> enemyDecks = {};
      enemyActionsByName.forEach((enemyName, actions) {
        enemyDecks[enemyName] = actions.map(enemyActionToGameCard).toList();
      });
      CombatManager().setEnemyActionsByName(enemyActionsByName);
      players = await loadCharactersFromCsv(
          'assets/data/players.csv', allCards, equipmentData,
          isEnemy: false);
      enemies = await loadEnemiesFromCsv('assets/data/enemies.csv', enemyDecks);
      // Save to local storage
      prefs.setString(
          'players', jsonEncode(players.map((e) => e.toJson()).toList()));
      // Save other data as before
      DataController.instance.set<List<GameCard>>('cards', allCards);
      DataController.instance
          .set<Map<String, EquipmentData>>('equipmentData', equipmentData);
    } else {
      // If loaded from local storage, still need to load enemies and cards for the game
      final allCards = await loadAllGameCards();
      final equipmentData =
          await loadEquipmentFromCsv('assets/data/equipment.csv');
      final enemyActionsByName =
          await loadEnemyActionsFromCsv('assets/data/enemy_actions.csv');
      final Map<String, List<GameCard>> enemyDecks = {};
      enemyActionsByName.forEach((enemyName, actions) {
        enemyDecks[enemyName] = actions.map(enemyActionToGameCard).toList();
      });
      CombatManager().setEnemyActionsByName(enemyActionsByName);
      enemies = await loadEnemiesFromCsv('assets/data/enemies.csv', enemyDecks);
      DataController.instance.set<List<GameCard>>('cards', allCards);
      DataController.instance
          .set<Map<String, EquipmentData>>('equipmentData', equipmentData);
    }

    DataController.instance.set<List<GameCharacter>>('players', players);
    DataController.instance.set<List<GameCharacter>>('enemies', enemies);

    // Set selected player
    GameCharacter? selectedPlayer;
    if (selectedPlayerName != null) {
      final found = players.where((p) => p.name == selectedPlayerName);
      if (found.isNotEmpty) {
        selectedPlayer = found.first;
      }
    }
    if (selectedPlayer == null && players.isNotEmpty) {
      selectedPlayer = players.first;
    }
    if (selectedPlayer != null) {
      DataController.instance
          .set<GameCharacter>('selectedPlayer', selectedPlayer);
      prefs.setString('selectedPlayerName', selectedPlayer.name);
    }
    // TODO: Persist selectedPlayer changes elsewhere in the app when user selects a new player.

    // Also store the parsed players.csv rows for equipment lookup
    final playersCsvString =
        await rootBundle.loadString('assets/data/players.csv');
    final playersCsvRows = const CsvToListConverter(eol: '\n')
        .convert(playersCsvString, eol: '\n');
    DataController.instance.set<List<List<dynamic>>>(
        'playersCsv', playersCsvRows.skip(1).toList());

    // Initialize audio configuration
    await AudioConfig.initialize();
    GameLogger.info(LogCategory.audio, 'Audio configuration initialized');

    // Initialize sound system
    await _soundManager.initialize();
    GameLogger.info(LogCategory.audio, 'Sound system initialized');

    // Initialize scene manager and load initial scene
    SceneManager().initialize(this);
    SceneManager().moveScene('title');
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.info(LogCategory.system, 'Game mounted');
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  void onRemove() {
    GameLogger.debug(
        LogCategory.system, 'Game being removed, cleaning up resources');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameLogger.debug(
        LogCategory.system, 'Game resized to: ${size.x}x${size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > 0.1) {
      GameLogger.warning(LogCategory.system, 'Game update with high dt: $dt');
    }
  }

  @override
  void render(Canvas canvas) {
    try {
      super.render(canvas);
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.system, 'Error in render: $e');
      GameLogger.debug(LogCategory.system, 'Stack trace: $stackTrace');
      rethrow;
    }
  }
}
