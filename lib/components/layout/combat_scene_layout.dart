import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/player_panel.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CombatSceneLayout extends Component {
  final Vector2 size;
  final PlayerPanel playerPanel;
  final CardsPanel cardsPanel;
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
    cardsPanel = CardsPanel(
      position: Vector2(0, size.y * 0.4),
      size: Vector2(size.x, size.y * 0.35),
    ),
    playerPanel = PlayerPanel(
      position: Vector2(0, size.y * 0.75),
      size: size,
      player: combatManager.player,
      onCardPlayed: onCardPlayed,
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
    add(cardsPanel);
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

    // Update cards panel
    cardsPanel.updateGameInfo('Cards in hand: ${combatManager.player.hand.length}');
    updateCards(combatManager.player.hand, combatManager.isPlayerTurn);

    // Update player panel
    playerPanel.updateUI(combatManager);
  }

  void updateCards(List<GameCard> cards, bool isPlayerTurn) {
    // Clear existing cards
    cardsPanel.removeAll(cardsPanel.children.where((c) => c is CardVisualComponent));
    
    // Add new cards
    for (var i = 0; i < cards.length; i++) {
      _addCardToHand(cards[i], i, isPlayerTurn);
    }
  }

  void _addCardToHand(GameCard card, int index, bool isPlayerTurn) {
    final cardWidth = CardsPanel.cardWidth;
    final cardHeight = CardsPanel.cardHeight;
    
    GameLogger.info(LogCategory.game, 'Adding card to hand: ${card.name}');
    
    final position = cardsPanel.calculateCardPosition(index);
    
    final cardComponent = CardVisualComponent(
      card,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: (card) => combatManager.playCard(card),
      enabled: isPlayerTurn,
    );
    
    cardsPanel.add(cardComponent);
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