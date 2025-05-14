import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/panel/player_panel.dart';
import 'package:card_combat_app/components/panel/cards_panel.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/panel/enemy_panel.dart';

class CombatSceneLayout extends PositionComponent with HasGameRef, VerticalStackMixin {
  late final List<BasePanel> panels;
  late final TextComponent turnText;
  late final TextComponent gameMessageText;
  bool _isInitialized = false;
  late final EnemyPanel enemyPanel;
  late final CardsPanel cardsPanel;

  CombatSceneLayout() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: onLoad started');
    await super.onLoad();
    final player = DataController.instance.get('selectedPlayer');
    final enemy = DataController.instance.get('selectedEnemy');
    if (player == null || enemy == null) {
      GameLogger.error(LogCategory.game, 'CombatSceneLayout: player or enemy not set in DataController');
      GameLogger.info(LogCategory.game, 'CombatSceneLayout: onLoad aborted due to missing player/enemy');
      return;
    }
    size = gameRef.size;
    CombatManager().initialize(player: player, enemy: enemy);

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
    cardsPanel = CardsPanel(player: player);
    // Connect card tap to game logic
    cardsPanel.onCardPlayed = (card) {
      if (!CombatManager().isPlayerTurn) return;
      CombatManager().playCard(card);
      updateUI();
      if (CombatManager().isCombatOver()) {
        // Optionally, show game over message here
        return;
      }
      // End player turn and trigger enemy turn after a delay
      CombatManager().endPlayerTurn();
      updateUI();
      Future.delayed(const Duration(seconds: 1), () {
        CombatManager().executeEnemyTurn();
        updateUI();
        if (CombatManager().isCombatOver()) {
          // Optionally, show game over message here
        }
      });
    };
    enemyPanel = EnemyPanel(mode: EnemyPanelMode.combat);
    panels = [
      cardsPanel,
      PlayerPanel(player: player),
      enemyPanel,
    ];

    // Initialize PlayerPanel with CombatManager singleton
    (panels[1] as PlayerPanel).initialize(player, CombatManager());

    // Add panels to the scene using vertical stack
    resetVerticalStack();
    addToVerticalStack(panels[2], size.y * 0.4); // Enemy panel (top)
    addToVerticalStack(turnText, 40);
    addToVerticalStack(panels[0], size.y * 0.2); // Cards panel (middle)
    addToVerticalStack(gameMessageText, 40);
    addToVerticalStack(panels[1], size.y * 0.1); // Player panel (bottom)

    // Add text components

    _isInitialized = true;
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: onLoad completed, calling updateUI');
    updateUI();
    registerWatchers(CombatManager());
  }

  /// Helper to format the enemy's next action with emojis
  String formatEnemyActionWithEmojis(EnemyBase enemy, GameCard action) {
    return ActionWithEmojiComponent.format(enemy, action);
  }

  void updateUI() {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: updateUI called');
    if (!_isInitialized) {
      GameLogger.info(LogCategory.game, 'CombatSceneLayout: updateUI early return, not initialized');
      return;
    }

    final enemy = DataController.instance.get('selectedEnemy');
    if (enemy != null) {
      turnText.text = CombatManager().isPlayerTurn ? "Player's Turn" : "${enemy.name}'s Turn";
      // Update enemy's next action with emojis
      final nextAction = CombatManager().enemy.getNextAction();
      (panels[2] as EnemyPanel).updateAction(formatEnemyActionWithEmojis(CombatManager().enemy, nextAction));
      (panels[2] as EnemyPanel).updateHealth();
    }

    // Update all panels
    for (var panel in panels) {
      panel.updateUI();
    }
  }

  void showGameMessage(String message) {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: showGameMessage: '
        '[33m$message[0m');
    gameMessageText.text = message;
    if (!children.contains(gameMessageText)) {
      add(gameMessageText);
    }
  }

  void hideGameMessage() {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: hideGameMessage called');
    if (children.contains(gameMessageText)) {
      gameMessageText.removeFromParent();
    }
  }

  void registerWatchers(CombatManager manager) {
    manager.addWatcher(enemyPanel);
    manager.addWatcher(panels[1] as PlayerPanel);
  }
} 