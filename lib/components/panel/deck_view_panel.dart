import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/models/game_card.dart';

class DeckViewPanel extends PositionComponent {
  final List<GameCard> cards;
  final Function(GameCard) onCardRemoved;
  final Function() onClose;

  DeckViewPanel({
    required this.cards,
    required this.onCardRemoved,
    required this.onClose,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    add(RectangleComponent(
      size: size,
      paint: material.Paint()..color = material.Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add title
    add(TextComponent(
      text: 'Deck',
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 24,
          fontWeight: material.FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 20),
    ));

    // Add close button
    add(SimpleButtonComponent.text(
      text: 'Close',
      size: Vector2(100, 40),
      color: material.Colors.red,
      onPressed: onClose,
      position: Vector2(size.x - 60, 20),
    ));

    // Add card list
    double yOffset = 80;
    for (var card in cards) {
      // Add card name
      add(TextComponent(
        text: card.name,
        textRenderer: TextPaint(
          style: const material.TextStyle(
            color: material.Colors.white,
            fontSize: 16,
          ),
        ),
        anchor: Anchor.topLeft,
        position: Vector2(20, yOffset),
      ));

      // Add remove button
      add(SimpleButtonComponent.text(
        text: 'Remove',
        size: Vector2(80, 30),
        color: material.Colors.red,
        onPressed: () => onCardRemoved(card),
        position: Vector2(size.x - 60, yOffset),
      ));

      yOffset += 40;
    }
  }
}
