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

class CardsPanel extends BasePanel {
  final TextComponent cardAreaText;
  final GameCharacter player;
  void Function(GameCard card)? onCardPlayed;

  List<CardVisualComponent> cardVisuals = [];
  List<bool> cardVisualsVisible = [];
  GameCard? selectedCard;
  ButtonComponent? playButton;
  CardDetailPanel? cardDetailPanel;
  ButtonComponent? endTurnButton;
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
    registerVerticalStackComponent('cardAreaText', cardAreaText, 40);
    // Show the player's hand as cards
    _showHand();
    // Add Play button (not attached by default)
    playButton = ButtonComponent(
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
        print('[PlayButton] Pressed. selectedCard: \\${selectedCard?.name}');
        if (onCardPlayed != null && selectedCard != null) {
          onCardPlayed!(selectedCard!);
          selectedCard = null;
          _hidePlayButton();
          _showEndTurnButton();
          if (cardDetailPanel != null) {
            cardDetailPanel!.showDeckAndDiscardInfo(player.deck.length, player.discardPile.length);
            cardDetailPanel!.isVisible = true;
          }
        }
      },
    );
    // Do not add playButton yet
    // Add End Turn button (attached by default)
    endTurnButton = ButtonComponent(
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
        print('[EndTurnButton] Pressed. selectedCard: \\${selectedCard?.name}');
        if (onEndTurn != null) {
          onEndTurn!();
        }
      },
    );
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
    // Remove all old visuals
    for (final visual in cardVisuals) {
      visual.removeFromParent();
    }
    cardVisuals.clear();
    cardVisualsVisible.clear();
    // Add visuals for current hand
    for (int i = 0; i < player.hand.length; i++) {
      final card = player.hand[i];
      final cardVisual = GameEffects.createCardVisual(
        card,
        i,
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
      add(cardVisual);
      cardVisuals.add(cardVisual);
      cardVisualsVisible.add(true);
    }
    _hidePlayButton();
    _showEndTurnButton();

    // Show deck/discard info if no card is selected
    if (cardDetailPanel != null && selectedCard == null) {
      cardDetailPanel!.showDeckAndDiscardInfo(player.deck.length, player.discardPile.length);
      cardDetailPanel!.isVisible = true;
    }
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
    if (playButton != null && playButton!.parent == null) {
      add(playButton!);
    }
    if (endTurnButton != null && endTurnButton!.parent != null) {
      endTurnButton!.removeFromParent();
    }
  }

  void _hidePlayButton() {
    if (playButton != null && playButton!.parent != null) {
      playButton!.removeFromParent();
    }
  }

  void _showEndTurnButton() {
    if (endTurnButton != null && endTurnButton!.parent == null) {
      add(endTurnButton!);
    }
    if (playButton != null && playButton!.parent != null) {
      playButton!.removeFromParent();
    }
  }

  void _hideEndTurnButton() {
    if (endTurnButton != null && endTurnButton!.parent != null) {
      endTurnButton!.removeFromParent();
    }
  }
} 