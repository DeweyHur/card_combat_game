import 'package:flutter/material.dart' as material;
import 'package:flame/components.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class CardUpgradePanel extends PositionComponent {
  final List<Card> cards;
  final Function(Card) onCardUpgraded;
  final Function(CardUpgradePanel) onClose;

  CardUpgradePanel({
    required this.cards,
    required this.onCardUpgraded,
    required this.onClose,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Title
    add(TextComponent(
      text: 'Upgrade a Card',
      position: Vector2(100, 50),
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
      text: 'Choose a card to upgrade:',
      position: Vector2(100, 100),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 18,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Card buttons
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      add(ButtonComponent(
        label: card.toString(),
        onPressed: () {
          card.upgrade();
          onCardUpgraded(card);
          onClose(this);
        },
        position: Vector2(100, 150 + i * 80),
      ));
    }

    // Close button
    add(ButtonComponent(
      label: 'Cancel',
      onPressed: () => onClose(this),
      position: Vector2(100, 150 + cards.length * 80),
    ));
  }
}
