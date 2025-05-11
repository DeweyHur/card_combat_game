import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/player_panel.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CombatSceneLayout extends Component {
  final Vector2 size;
  final PlayerPanel playerPanel;
  final TextComponent turnText;
  final TextComponent enemyNextActionText;
  final TextComponent enemyHealthText;
  final TextComponent gameMessageText;

  late CombatManager combatManager;

  CombatSceneLayout({
    required this.size,
    required CombatManager combatManager,
    required Function(GameCard) onCardPlayed,
  }) : 
    turnText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.5, size.y * 0.1),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
    enemyNextActionText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.5, size.y * 0.15),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
    enemyHealthText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.8, size.y * 0.05),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
    gameMessageText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.5, size.y * 0.5),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
    playerPanel = PlayerPanel(
      size: size,
      player: combatManager.player,
      onCardPlayed: onCardPlayed,
      position: Vector2(0, size.y * 0.75),
    ) {
    this.combatManager = combatManager;
  }

  void initialize(CombatManager combatManager) {
    this.combatManager = combatManager;
    playerPanel.initialize(combatManager.player, combatManager);
    updateUI(combatManager);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(playerPanel);
    add(turnText);
    add(enemyNextActionText);
    add(enemyHealthText);
  }

  void updateUI(CombatManager combatManager) {
    // Update turn text
    turnText.text = combatManager.isPlayerTurn ? "Player's Turn" : "${combatManager.enemy.name}'s Turn";
    
    // Update enemy's next action
    enemyNextActionText.text = 'Next: ${combatManager.enemy.getNextAction()}';
    
    // Update enemy health display
    enemyHealthText.text = '${combatManager.enemy.name}: ${combatManager.enemy.currentHealth}/${combatManager.enemy.maxHealth}';

    // Update player panel
    playerPanel.updateUI(combatManager);
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