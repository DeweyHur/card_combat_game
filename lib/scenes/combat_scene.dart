import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/enemy.dart';
import 'package:card_combat_app/components/layout/combat_scene_layout.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/player_combat_panel.dart';
import 'package:card_combat_app/components/panel/enemy_combat_panel.dart';

class CombatScene extends BaseScene with HasGameReference {
  late final CombatSceneLayout _layout;
  late final PlayerRun playerRun;
  late final EnemyRun enemyRun;
  late final PlayerCombatPanel playerPanel;
  late final EnemyCombatPanel enemyPanel;
  bool _combatEnded = false;

  CombatScene({Map<String, dynamic>? options})
      : super(
          sceneBackgroundColor: const material.Color(0xFF1A1A2E),
          options: options,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    playerRun = DataController.instance.get<PlayerRun>('selectedPlayer')!;
    enemyRun = DataController.instance.get<EnemyRun>('selectedEnemy')!;
    _layout = CombatSceneLayout();
    add(_layout);
    CombatManager().startCombat();
    GameLogger.info(LogCategory.game,
        'Combat started: \x1B[32m${playerRun.name}\x1B[0m vs \x1B[31m${enemyRun.name}\x1B[0m');

    playerPanel = PlayerCombatPanel(playerRun: playerRun);
    enemyPanel = EnemyCombatPanel(enemy: enemyRun);

    await add(playerPanel);
    await add(enemyPanel);

    playerPanel.initialize(CombatManager());
    enemyPanel.initialize(CombatManager());
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
    CombatManager().endTurn();
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
