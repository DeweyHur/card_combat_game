import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/combat_scene_layout.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'base_scene.dart';

class CombatScene extends BaseScene with HasGameRef {
  late final CombatManager _combatManager;
  late final CombatSceneLayout _layout;
  late final dynamic player;
  late final dynamic enemy;

  CombatScene() : super(
    sceneBackgroundColor: const Color(0xFF1A1A2E),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    player = DataController.instance.get('selectedPlayer');
    enemy = DataController.instance.get('selectedEnemy');
    if (player == null || enemy == null) {
      GameLogger.error(LogCategory.game, 'CombatScene: player or enemy not set in DataController');
      return;
    }
    _combatManager = CombatManager(player: player, enemy: enemy);
    _layout = CombatSceneLayout(
      gameSize: gameRef.size,
      player: player,
      enemy: enemy,
    );
    add(_layout);
    _combatManager.startCombat();
    GameLogger.info(LogCategory.game, 'Combat started: [32m${player.name}[0m vs [31m${enemy.name}[0m');
  }

  void _handleCardPlayed(GameCard card) {
    if (!_combatManager.isPlayerTurn) return;

    _combatManager.playCard(card);
    _layout.updateUI();

    if (_combatManager.isCombatOver()) {
      handleCombatEnd();
      return;
    }

    // Log before ending turn automatically
    GameLogger.info(LogCategory.game, 'Auto-ending player turn after card play.');
    endTurn();
  }

  void handleCombatEnd() {
    final result = _combatManager.getCombatResult();
    if (result != null) {
      GameLogger.info(LogCategory.game, 'Combat ended: $result');
      _layout.showGameMessage(result);
    }
  }

  void endTurn() {
    if (!_combatManager.isPlayerTurn) return;

    _combatManager.endPlayerTurn();
    _layout.updateUI();

    // Execute enemy turn after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      _combatManager.executeEnemyTurn();
      _layout.updateUI();

      if (_combatManager.isCombatOver()) {
        handleCombatEnd();
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_combatManager.isCombatOver()) {
      final result = _combatManager.getCombatResult();
      GameLogger.info(LogCategory.combat, 'Combat ended: $result');
      // TODO: Handle combat end
    }
  }
} 