import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';

class CardsPanel extends BasePanel {
  final TextComponent cardAreaText;
  final TextComponent gameInfoText;
  final TextComponent turnText;
  final PlayerBase player;

  List<CardVisualComponent> cardVisuals = [];

  CardsPanel({
    required this.player,
  }) : 
    cardAreaText = TextComponent(
      text: 'Your Hand',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    ),
    gameInfoText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    ),
    turnText = TextComponent(
      text: 'Turn: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add text components using vertical stack
    resetVerticalStack();
    addToVerticalStack(cardAreaText, 40);
    addToVerticalStack(gameInfoText, 32);
    addToVerticalStack(turnText, 32);

    // Show the player's hand as cards
    _showHand();
  }

  void _showHand() {
    // Remove old card visuals
    for (final cardVisual in cardVisuals) {
      cardVisual.removeFromParent();
    }
    cardVisuals.clear();

    // Add new card visuals for each card in hand
    for (int i = 0; i < player.hand.length; i++) {
      final card = player.hand[i];
      final cardVisual = GameEffects.createCardVisual(
        card,
        i,
        Vector2(0, 0), // CardsPanel's own position/size
        size,
        (playedCard) => playCard(playedCard),
        true, // isPlayerTurn (stubbed for now)
      ) as CardVisualComponent;
      add(cardVisual);
      cardVisuals.add(cardVisual);
    }
  }

  void playCard(card) {
    // TODO: Implement play card logic, e.g., call CombatManager.playCard(card)
    // For now, just log
    GameLogger.info(LogCategory.ui, 'Card played: [32m${card.name}[0m');
  }

  void updateGameInfo(String info) {
    gameInfoText.text = info;
  }

  void updateTurn(int turn) {
    turnText.text = 'Turn: $turn';
  }

  Vector2 calculateCardPosition(int index) {
    final totalWidth = (CardVisualComponent.maxCards * CardVisualComponent.cardWidth) + ((CardVisualComponent.maxCards - 1) * CardVisualComponent.cardSpacing);
    final startX = (size.x - totalWidth) / 2;

    final pos = Vector2(
      startX + (index * (CardVisualComponent.cardWidth + CardVisualComponent.cardSpacing)),
      CardVisualComponent.cardTopMargin,
    );

    return pos;
  }

  @override
  void updateUI() {
    // Update any UI elements that need to be refreshed
    // This could include updating card positions, turn information, etc.
    _showHand();
  }
} 