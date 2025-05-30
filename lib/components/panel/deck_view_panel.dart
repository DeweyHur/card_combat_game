import 'package:flutter/material.dart' as material;
import 'package:flame/components.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class DeckViewPanel extends PositionComponent {
  final List<Card> cards;
  final Function(Card) onCardRemoved;
  final Function(DeckViewPanel) onClose;

  DeckViewPanel({
    required this.cards,
    required this.onCardRemoved,
    required this.onClose,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Title
    add(TextComponent(
      text: 'Your Deck',
      position: Vector2(100.0, 50.0),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 32,
          color: material.Colors.black,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    ));

    // Description
    add(TextComponent(
      text: 'View your cards or remove one:',
      position: Vector2(100.0, 100.0),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 18,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Card list with remove buttons
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final yPos = 150.0 + i * 80.0;

      // Card info
      add(TextComponent(
        text: card.toString(),
        position: Vector2(100.0, yPos),
        textRenderer: TextPaint(
          style: const material.TextStyle(
            fontSize: 16,
            color: material.Colors.black87,
          ),
        ),
      ));

      // Remove button
      add(ButtonComponent(
        label: 'Remove',
        onPressed: () {
          onCardRemoved(card);
          onClose(this);
        },
        position: Vector2(400.0, yPos),
      ));
    }

    // Close button
    add(ButtonComponent(
      label: 'Close',
      onPressed: () => onClose(this),
      position: Vector2(100.0, 150.0 + cards.length * 80.0),
    ));
  }
}
