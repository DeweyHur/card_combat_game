import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class PlayerPanel extends Component {
  final Vector2 size;
  final CardsPanel cardsPanel;
  final TextComponent playerHealthText;
  final List<CardVisualComponent> cardComponents = [];

  late CombatManager combatManager;

  PlayerPanel({
    required this.size,
    required PlayerBase player,
    required Function(GameCard) onCardPlayed,
    Vector2? position,
  }) : 
    cardsPanel = CardsPanel(
      position: Vector2(0, size.y * 0.75),
      size: Vector2(size.x * 0.8, size.y * 0.2),
    ),
    playerHealthText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.2, size.y * 0.05),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ) {
    this.position = position ?? Vector2.zero();
  }

  void initialize(PlayerBase player, CombatManager combatManager) {
    this.combatManager = combatManager;
    updateUI(combatManager);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.ui, 'PlayerPanel mounted at position ${position.x},${position.y} with size ${size.x}x${size.y}');
    GameLogger.info(LogCategory.ui, 'CardsPanel mounted at position ${cardsPanel.position.x},${cardsPanel.position.y} with size ${cardsPanel.size.x}x${cardsPanel.size.y}');
    add(cardsPanel);
    add(playerHealthText);
  }

  void updateUI(CombatManager combatManager) {
    // Update health display
    playerHealthText.text = '${combatManager.player.name}: ${combatManager.player.currentHealth}/${combatManager.player.maxHealth}';

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
} 