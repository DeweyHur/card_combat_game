import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/panel/card_detail_panel.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart' show HasVisibility;
import 'package:card_combat_app/components/panel/visible_button_component.dart';

class VisibleButtonComponent extends ButtonComponent with HasVisibility {
  VisibleButtonComponent({
    required super.button,
    super.position,
    super.size,
    super.anchor,
    super.onPressed,
  });
}

class CardsPanel extends BasePanel {
  final TextComponent cardAreaText;
  final GameCharacter player;
  void Function(GameCard card)? onCardPlayed;

  List<CardVisualComponent> cardVisuals = [];
  List<bool> cardVisualsVisible = [];
  GameCard? selectedCard;
  VisibleButtonComponent? playButton;
  CardDetailPanel? cardDetailPanel;
  VisibleButtonComponent? endTurnButton;
  void Function()? onEndTurn;
  
  final double buttonHeight = 120.0;

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
    playButton = VisibleButtonComponent(
      button: RectangleComponent(
        size: Vector2(size.x / 2, buttonHeight),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.topLeft,
        children: [
          TextComponent(
            text: 'Play',
            textRenderer: TextPaint(
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            size: Vector2(size.x / 2, buttonHeight),
            position: Vector2((size.x / 2) / 2, buttonHeight / 2),
            anchor: Anchor.center,
          ),
        ],
      ),
      position: Vector2(0, size.y),
      anchor: Anchor.bottomLeft,
      onPressed: () {
        if (onCardPlayed != null && selectedCard != null) {
          onCardPlayed!(selectedCard!);
          selectedCard = null;
          _hidePlayButton();
          _showEndTurnButton();
          if (cardDetailPanel != null) {
            cardDetailPanel!.isVisible = false;
          }
        }
      },
    );
    playButton!.isVisible = false;
    add(playButton!);
    // Add End Turn button (hidden by default)
    endTurnButton = VisibleButtonComponent(
      button: RectangleComponent(
        size: Vector2(size.x / 2, buttonHeight),
        paint: Paint()..color = Colors.orange,
        anchor: Anchor.topLeft,
        children: [
          TextComponent(
            text: 'End Turn',
            textRenderer: TextPaint(
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            size: Vector2(size.x / 2, buttonHeight),
            position: Vector2((size.x / 2) / 2, buttonHeight / 2),
            anchor: Anchor.center,
          ),
        ],
      ),
      position: Vector2(0, size.y),
      anchor: Anchor.bottomLeft,
      onPressed: () {
        if (onEndTurn != null) {
          onEndTurn!();
        }
      },
    );
    endTurnButton!.isVisible = true;
    add(endTurnButton!);
    // Create card detail panel once, hidden by default
    cardDetailPanel = CardDetailPanel(
      position: Vector2(size.x / 2, size.y - buttonHeight),
      size: Vector2(size.x / 2, buttonHeight),
    );
    cardDetailPanel!.isVisible = false;
    add(cardDetailPanel!);
  }

  void _showHand() {
    // Hide card detail panel
    if (cardDetailPanel != null) {
      cardDetailPanel!.isVisible = false;
    }
    // Ensure cardVisuals list matches hand size
    while (cardVisuals.length < player.deck.length) {
      // Create new CardVisualComponent with HasVisibility
      final idx = cardVisuals.length;
      final card = player.deck[idx];
      final cardVisual = GameEffects.createCardVisual(
        card,
        idx,
        Vector2(0, 0),
        size,
        (selected) async {
          if (player.currentEnergy < card.cost) return;
          selectedCard = selected;
          _hideEndTurnButton();
          _showPlayButton();
          if (cardDetailPanel != null) {
            cardDetailPanel!.isVisible = true;
            cardDetailPanel!.setCard(selectedCard!);
          }
        },
        player.currentEnergy >= card.cost,
      ) as CardVisualComponent;
      if (cardVisual is HasVisibility) {
        cardVisual.isVisible = false;
      }
      add(cardVisual);
      cardVisuals.add(cardVisual);
      cardVisualsVisible.add(false);
    }
    // Hide all visuals first
    for (final visual in cardVisuals) {
      if (visual is HasVisibility) visual.isVisible = false;
    }
    // Show and update only the ones in hand
    for (int i = 0; i < player.deck.length; i++) {
      final card = player.deck[i];
      final visual = cardVisuals[i];
      if (visual is HasVisibility) visual.isVisible = true;
      // Optionally update card data if needed (if visuals are reused)
      // visual.cardData = card; // If you want to support dynamic hand changes
    }
    _hidePlayButton();
    _showEndTurnButton();
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
    _showHand();
  }

  void _showPlayButton() {
    if (playButton != null) playButton!.isVisible = true;
    if (endTurnButton != null) endTurnButton!.isVisible = false;
  }

  void _hidePlayButton() {
    if (playButton != null) playButton!.isVisible = false;
  }

  void _showEndTurnButton() {
    if (endTurnButton != null) endTurnButton!.isVisible = true;
    if (playButton != null) playButton!.isVisible = false;
  }

  void _hideEndTurnButton() {
    if (endTurnButton != null) endTurnButton!.isVisible = false;
  }
} 