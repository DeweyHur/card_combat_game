import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'dart:ui';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/simple_button_component.dart';

class DeckViewPanel extends BasePanel {
  final List<CardRun> cards;
  final Function(CardRun)? onCardRemoved;
  final Function()? onClose;

  DeckViewPanel({
    required Vector2 position,
    required Vector2 size,
    required this.cards,
    this.onCardRemoved,
    this.onClose,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add semi-transparent black background
    add(RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = material.Colors.black.withOpacity(0.8),
    ));

    // Add title
    add(TextComponent(
      text: 'Your Deck',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: material.TextStyle(
          fontSize: 24,
          color: material.Colors.white,
        ),
      ),
    ));

    // Add card list
    final cardY = 60.0;
    final cardSpacing = 40.0;
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final y = cardY + i * cardSpacing;

      // Card name
      add(TextComponent(
        text: card.name,
        position: Vector2(20, y),
        textRenderer: TextPaint(
          style: material.TextStyle(
            fontSize: 16,
            color: material.Colors.white,
          ),
        ),
      ));

      // Remove button
      add(SimpleButtonComponent.text(
        text: 'Remove',
        position: Vector2(size.x - 100, y),
        size: Vector2(80, 30),
        color: material.Colors.red,
        onPressed: () {
          onCardRemoved?.call(card);
        },
      ));
    }

    // Add close button
    add(SimpleButtonComponent.text(
      text: 'Close',
      position: Vector2(size.x / 2, size.y - 40),
      size: Vector2(100, 40),
      color: material.Colors.grey,
      onPressed: () {
        onClose?.call();
      },
    ));
  }

  @override
  void updateUI() {
    // No updates needed as the card list is static
  }
}
