import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/panel/cards_panel.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/panel/enemy_combat_panel.dart';
import 'package:card_combat_app/components/panel/player_combat_panel.dart';
import 'package:card_combat_app/models/game_character.dart';

class CombatSceneLayout extends PositionComponent
    with HasGameReference, VerticalStackMixin {
  static CombatSceneLayout? current;
  late final List<BasePanel> panels;
  late final TextComponent turnText;
  late final TextComponent gameMessageText;
  bool _isInitialized = false;
  late final EnemyCombatPanel enemyPanel;
  late final CardsPanel cardsPanel;

  CombatSceneLayout() : super(anchor: Anchor.topLeft) {
    CombatSceneLayout.current = this;
  }

  @override
  Future<void> onLoad() async {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: onLoad started');
    await super.onLoad();
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    final enemy = DataController.instance.get<GameCharacter>('selectedEnemy');
    if (player == null || enemy == null) {
      GameLogger.error(LogCategory.game,
          'CombatSceneLayout: player or enemy not set in DataController');
      GameLogger.info(LogCategory.game,
          'CombatSceneLayout: onLoad aborted due to missing player/enemy');
      return;
    }
    size = findGame()!.size;
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
      // Do NOT end player turn here; allow multiple cards to be played
    };
    cardsPanel.onEndTurn = () {
      if (!CombatManager().isPlayerTurn) return;
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
    enemyPanel = EnemyCombatPanel();
    panels = [
      cardsPanel,
      PlayerCombatPanel(player: player),
      enemyPanel,
    ];

    // Initialize PlayerPanel with CombatManager singleton
    (panels[1] as PlayerCombatPanel).initialize(player, CombatManager());

    // Add panels to the scene using vertical stack
    resetVerticalStack();
    registerVerticalStackComponent(
        'enemyPanel', panels[2], size.y * 0.4); // Enemy panel (top)
    registerVerticalStackComponent('turnText', turnText, 40);
    registerVerticalStackComponent(
        'cardsPanel', panels[0], size.y * 0.3); // Cards panel (middle)
    registerVerticalStackComponent('gameMessageText', gameMessageText, 40);
    registerVerticalStackComponent(
        'playerPanel', panels[1], size.y * 0.15); // Player panel (bottom)

    // Add text components

    _isInitialized = true;
    GameLogger.info(LogCategory.game,
        'CombatSceneLayout: onLoad completed, calling updateUI');
    registerWatchers(CombatManager());
  }

  @override
  void onMount() {
    super.onMount();
    updateUI();
  }

  /// Helper to format the enemy's next action with emojis
  String formatEnemyActionWithEmojis(GameCharacter enemy, GameCard action) {
    return ActionWithEmojiComponent.format(enemy, action);
  }

  void updateUI() {
    GameLogger.info(LogCategory.game, 'CombatSceneLayout: updateUI called');
    if (!_isInitialized) {
      GameLogger.info(LogCategory.game,
          'CombatSceneLayout: updateUI early return, not initialized');
      return;
    }

    final enemy = DataController.instance.get('selectedEnemy');
    if (enemy != null) {
      turnText.text = CombatManager().isPlayerTurn
          ? "Player's Turn"
          : "${enemy.name}'s Turn";
      // Use the last picked enemy action as the next action
      final nextAction = CombatManager().lastEnemyAction ??
          (CombatManager().enemy.deck.isNotEmpty
              ? CombatManager().enemy.deck.first
              : null);
      if (nextAction != null) {
        (panels[2] as EnemyCombatPanel).updateActionWithDescription(
          formatEnemyActionWithEmojis(CombatManager().enemy, nextAction),
          nextAction.description,
        );
      }
      (panels[2] as EnemyCombatPanel).updateHealth();
    }

    // Update all panels
    for (var panel in panels) {
      panel.updateUI();
    }
  }

  void showGameMessage(String message) {
    GameLogger.info(
        LogCategory.game,
        'CombatSceneLayout: showGameMessage: '
        '[33m$message[0m');
    gameMessageText.text = message;
    if (!children.contains(gameMessageText)) {
      add(gameMessageText);
    }
  }

  void hideGameMessage() {
    GameLogger.info(
        LogCategory.game, 'CombatSceneLayout: hideGameMessage called');
    if (children.contains(gameMessageText)) {
      gameMessageText.removeFromParent();
    }
  }

  void registerWatchers(CombatManager manager) {
    manager.addWatcher(enemyPanel);
    manager.addWatcher(panels[1] as PlayerCombatPanel);
  }
}
