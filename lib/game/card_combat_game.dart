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

class CardCombatGame extends FlameGame with TapDetector, HasCollisionDetection {
  final SoundManager _soundManager = SoundManager();

  CardCombatGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame loading...');

    // Load all cards
    final allCards = await loadAllGameCards();
    // Load equipment
    final equipmentData = await loadEquipmentFromCsv('assets/data/equipment.csv');
    // Load enemy actions and convert to GameCards
    final enemyActionsByName = await loadEnemyActionsFromCsv('assets/data/enemy_actions.csv');
    final Map<String, List<GameCard>> enemyDecks = {};
    enemyActionsByName.forEach((enemyName, actions) {
      enemyDecks[enemyName] = actions.map(enemyActionToGameCard).toList();
    });
    // Pass enemyActionsByName to CombatManager for probability-based selection
    CombatManager().setEnemyActionsByName(enemyActionsByName);
    // Load players and enemies
    final players = await loadCharactersFromCsv('assets/data/players.csv', allCards, equipmentData, isEnemy: false);
    final enemies = await loadEnemiesFromCsv('assets/data/enemies.csv', enemyDecks);
    // Store in DataController
    DataController.instance.set<List<GameCharacter>>('players', players);
    DataController.instance.set<List<GameCharacter>>('enemies', enemies);
    DataController.instance.set<List<GameCard>>('cards', allCards);

    // Initialize audio configuration
    await AudioConfig.initialize();
    GameLogger.info(LogCategory.audio, 'Audio configuration initialized');

    // Initialize sound system
    await _soundManager.initialize();
    GameLogger.info(LogCategory.audio, 'Sound system initialized');

    // Initialize scene manager and load initial scene
    SceneManager().initialize(this);
    SceneManager().pushScene('title');
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
    GameLogger.debug(LogCategory.system, 'Game being removed, cleaning up resources');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameLogger.debug(LogCategory.system, 'Game resized to: ${size.x}x${size.y}');
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