import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CombatSceneLayout extends Component {
  final Vector2 size;
  final CardsPanel cardsPanel;
  final TextComponent turnText;
  final TextComponent enemyNextActionText;
  final TextComponent playerHealthText;
  final TextComponent enemyHealthText;
  final TextComponent gameMessageText;
  final List<CardVisualComponent> cardComponents = [];

  late CombatManager combatManager;

  CombatSceneLayout({
    required this.size,
    required PlayerBase player,
    required EnemyBase enemy,
    required Function(GameCard) onCardPlayed,
  }) : 
    cardsPanel = CardsPanel(
      position: Vector2(size.x / 2, size.y - 100),
      size: Vector2(size.x, 200),
    ),
    turnText = TextComponent(
      text: "Player's Turn",
      position: Vector2(size.x / 2, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
    ),
    enemyNextActionText = TextComponent(
      text: 'Next: ',
      position: Vector2(size.x / 2, 140),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.topCenter,
    ),
    playerHealthText = TextComponent(
      text: '',
      position: Vector2(50, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
    enemyHealthText = TextComponent(
      text: '',
      position: Vector2(size.x - 50, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topRight,
    ),
    gameMessageText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );

  void initialize(PlayerBase player, EnemyBase enemy, CombatManager combatManager) {
    this.combatManager = combatManager;
    updateUI(combatManager);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add components to the scene
    add(cardsPanel);
    add(turnText);
    add(enemyNextActionText);
    add(playerHealthText);
    add(enemyHealthText);
  }

  void updateUI(CombatManager combatManager) {
    // Update turn text
    turnText.text = combatManager.isPlayerTurn ? "Player's Turn" : "${combatManager.enemy.name}'s Turn";
    
    // Update enemy's next action
    enemyNextActionText.text = 'Next: ${combatManager.enemy.getNextAction()}';
    
    // Update health displays
    playerHealthText.text = '${combatManager.player.name}: ${combatManager.player.currentHealth}/${combatManager.player.maxHealth}';
    enemyHealthText.text = '${combatManager.enemy.name}: ${combatManager.enemy.currentHealth}/${combatManager.enemy.maxHealth}';

    // Update cards
    updateCards(combatManager.playerHand, combatManager.isPlayerTurn);
  }

  void updateCards(List<GameCard> cards, bool isPlayerTurn) {
    // Remove old cards
    for (var card in cardComponents) {
      cardsPanel.remove(card);
    }
    cardComponents.clear();

    // Add new cards
    for (var i = 0; i < cards.length; i++) {
      _addCardToHand(cards[i], i, isPlayerTurn);
    }
  }

  void _addCardToHand(GameCard card, int index, bool isPlayerTurn) {
    final cardWidth = CardsPanel.cardWidth;
    final cardHeight = CardsPanel.cardHeight;
    
    GameLogger.info(LogCategory.game, 'Adding card to hand: ${card.name}');
    
    // Calculate position using the CardsPanel's helper method
    final position = cardsPanel.calculateCardPosition(index);
    
    final cardComponent = CardVisualComponent(
      card,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: (card) => combatManager.playCard(card),
      enabled: isPlayerTurn,
    );
    
    // Add card to the cards panel
    cardsPanel.add(cardComponent);
    cardComponents.add(cardComponent);
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