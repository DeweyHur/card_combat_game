import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/combat_scene_layout.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'base_scene.dart';

class CombatScene extends BaseScene with HasGameRef {
  final PlayerBase player;
  final EnemyBase enemy;
  final CombatManager _combatManager;
  late final CombatSceneLayout _layout;

  CombatScene({
    required this.player,
    required this.enemy,
  }) : _combatManager = CombatManager(
         player: player,
         enemy: enemy,
       ),
       super(
         sceneBackgroundColor: const Color(0xFF1A1A2E),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    _layout = CombatSceneLayout(
      gameSize: gameRef.size,
      player: player,
      enemy: enemy,
    );
    add(_layout);
    _combatManager.startCombat();

    GameLogger.info(LogCategory.game, 'Combat started: ${player.name} vs ${enemy.name}');
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