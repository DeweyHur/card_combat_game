import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/panel/card_detail_panel.dart';
import 'package:flame/events.dart';

class CardsPanel extends BasePanel {
  final TextComponent cardAreaText;
  final PlayerBase player;
  void Function(GameCard card)? onCardPlayed;

  List<CardVisualComponent> cardVisuals = [];
  GameCard? selectedCard;
  PositionComponent? playButton;
  CardDetailPanel? cardDetailPanel;
  bool playButtonVisible = false;

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
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add text components using vertical stack
    resetVerticalStack();
    addToVerticalStack(cardAreaText, 40);

    // Show the player's hand as cards
    _showHand();

    // Add Play button (hidden by default)
    playButton = PositionComponent(
      size: Vector2(size.x/4, 140),
      position: Vector2( 0, size.y),
      anchor: Anchor.bottomLeft,
    )
      ..add(RectangleComponent(
        size: Vector2(size.x/2, 140),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Play',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          size: Vector2(size.x/2, 140),
          position: Vector2( size.x/4, size.y/4),
          anchor: Anchor.center,
        ),
      );
    playButtonVisible = false;
  }

  void _showHand() {
    // Remove old card visuals
    for (final cardVisual in cardVisuals) {
      cardVisual.removeFromParent();
    }
    cardVisuals.clear();
    // Remove card detail panel if present
    cardDetailPanel?.removeFromParent();
    cardDetailPanel = null;
    // Add new card visuals for each card in hand
    for (int i = 0; i < player.hand.length; i++) {
      final card = player.hand[i];
      final cardVisual = GameEffects.createCardVisual(
        card,
        i,
        Vector2(0, 0), // CardsPanel's own position/size
        size,
        (selected) async {
          selectedCard = selected;
          _showPlayButton();
          // Show CardDetailPanel for selectedCard
          cardDetailPanel?.removeFromParent();
          cardDetailPanel = CardDetailPanel(
            position: Vector2(size.x / 2, size.y - 140),
            size: Vector2(size.x / 2, 140),
          );
          add(cardDetailPanel!);
          await cardDetailPanel!.onLoad();
          cardDetailPanel!.setCard(selectedCard!);
        },
        true, // isPlayerTurn (stubbed for now)
      ) as CardVisualComponent;
      add(cardVisual);
      cardVisuals.add(cardVisual);
    }
    _hidePlayButton();
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

  @override
  bool onTapDown(TapDownInfo info) {
    final local = info.eventPosition.global;
    if (playButton != null && playButtonVisible && playButton!.toRect().contains(local.toOffset()) && selectedCard != null) {
      if (onCardPlayed != null) onCardPlayed!(selectedCard!);
      selectedCard = null;
      _hidePlayButton();
      // Hide CardDetailPanel
      cardDetailPanel?.removeFromParent();
      cardDetailPanel = null;
      return true;
    }
    return false;
  }

  void _showPlayButton() {
    if (!playButtonVisible && playButton != null) {
      add(playButton!);
      playButtonVisible = true;
    }
  }

  void _hidePlayButton() {
    if (playButtonVisible && playButton != null) {
      playButton!.removeFromParent();
      playButtonVisible = false;
    }
  }
} 