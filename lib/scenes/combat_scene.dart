import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/layout/combat_scene_layout.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class CombatScene extends BaseScene with HasGameRef {
  late final CombatSceneLayout _layout;
  late final GameCharacter player;
  late final GameCharacter enemy;
  bool _combatEnded = false;

  CombatScene() : super(
    sceneBackgroundColor: const Color(0xFF1A1A2E),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    player = DataController.instance.get<GameCharacter>('selectedPlayer')!;
    enemy = DataController.instance.get<GameCharacter>('selectedEnemy')!;
    if (player == null || enemy == null) {
      GameLogger.error(LogCategory.game, 'CombatScene: player or enemy not set in DataController');
      return;
    }
    CombatManager().initialize(player: player, enemy: enemy);
    _layout = CombatSceneLayout();
    add(_layout);
    CombatManager().startCombat();
    GameLogger.info(LogCategory.game, 'Combat started: \x1B[32m${player.name}\x1B[0m vs \x1B[31m${enemy.name}\x1B[0m');
  }

  void _handleCardPlayed(GameCard card) {
    if (!CombatManager().isPlayerTurn) return;
    CombatManager().playCard(card);
    _layout.updateUI();
    if (CombatManager().isCombatOver()) {
      handleCombatEnd();
      return;
    }
  }

  void handleCombatEnd() {
    if (_combatEnded) return;
    _combatEnded = true;
    final result = CombatManager().getCombatResult();
    if (result != null) {
      GameLogger.info(LogCategory.game, 'Combat ended: $result');
      DataController.instance.set('gameResult', result);
      SceneManager().pushScene('game_result');
    }
  }

  void endTurn() {
    if (!CombatManager().isPlayerTurn) return;

    CombatManager().endPlayerTurn();
    _layout.updateUI();

    // Execute enemy turn after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      CombatManager().executeEnemyTurn();
      _layout.updateUI();

      if (CombatManager().isCombatOver()) {
        handleCombatEnd();
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_combatEnded && CombatManager().isCombatOver()) {
      _combatEnded = true;
      final result = CombatManager().getCombatResult();
      GameLogger.info(LogCategory.combat, 'Combat ended: $result');
      DataController.instance.set('gameResult', result);
      SceneManager().pushScene('game_result');
    }
  }
} 