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

class CombatScene extends BaseScene {
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
         backgroundColor: const Color(0xFF1A1A2E),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    _layout = CombatSceneLayout(
      size: game.size,
      player: player,
      combatManager: _combatManager,
      onCardPlayed: _handleCardPlayed,
    );
    add(_layout);
    _combatManager.startCombat();

    // Initialize layout
    _layout.initialize(player, enemy, _combatManager);

    GameLogger.info(LogCategory.game, 'Combat started: ${player.name} vs ${enemy.name}');
  }

  void _handleCardPlayed(GameCard card) {
    if (!_combatManager.isPlayerTurn) return;

    _combatManager.playCard(card);
    _layout.updateUI(_combatManager);

    if (_combatManager.isCombatOver()) {
      handleCombatEnd();
    }
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
    _layout.updateUI(_combatManager);

    // Execute enemy turn after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      _combatManager.executeEnemyTurn();
      _layout.updateUI(_combatManager);

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