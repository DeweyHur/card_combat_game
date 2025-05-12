import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/panel/player_panel.dart';
import 'package:card_combat_app/components/panel/enemy_panel.dart';
import 'package:card_combat_app/components/panel/cards_panel.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class CombatSceneLayout extends PositionComponent with HasGameRef {
  late final List<BasePanel> panels;
  late final CombatManager combatManager;
  late final TextComponent turnText;
  late final TextComponent gameMessageText;
  bool _isInitialized = false;

  CombatSceneLayout() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final player = DataController.instance.get('selectedPlayer');
    final enemy = DataController.instance.get('selectedEnemy');
    if (player == null || enemy == null) {
      GameLogger.error(LogCategory.game, 'CombatSceneLayout: player or enemy not set in DataController');
      return;
    }
    size = gameRef.size;
    combatManager = CombatManager(player: player, enemy: enemy);

    // Initialize text components
    turnText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.5, size.y * 0.1),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );

    gameMessageText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.5, size.y * 0.5),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );

    // Initialize panels
    panels = [
      CardsPanel(player: player),
      PlayerPanel(player: player),
      EnemyPanel(enemy: enemy),
    ];

    // Add panels to the scene
    for (var panel in panels) {
      add(panel);
    }

    // Set panel positions
    panels[0].position = Vector2(0, size.y * 0.3); // Cards panel
    panels[1].position = Vector2(0, size.y * 0.7); // Player panel
    panels[2].position = Vector2(0, 0); // Enemy panel

    // Add text components
    add(turnText);
    add(gameMessageText);

    _isInitialized = true;
    updateUI();
  }

  void updateUI() {
    if (!_isInitialized) return;

    final enemy = DataController.instance.get('selectedEnemy');
    if (enemy != null) {
      turnText.text = combatManager.isPlayerTurn ? "Player's Turn" : "${enemy.name}'s Turn";
      // Update enemy's next action
      (panels[2] as EnemyPanel).updateAction(combatManager.enemy.getNextAction().name);
      // Update enemy health
      (panels[2] as EnemyPanel).updateHealth();
    }

    // Update all panels
    for (var panel in panels) {
      panel.updateUI();
    }
  }

  void showGameMessage(String message) {
    gameMessageText.text = message;
    if (!children.contains(gameMessageText)) {
      add(gameMessageText);
    }
  }

  void hideGameMessage() {
    if (children.contains(gameMessageText)) {
      gameMessageText.removeFromParent();
    }
  }
} 