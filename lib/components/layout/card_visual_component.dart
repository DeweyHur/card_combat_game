import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:card_combat_app/models/card.dart';

class CardVisualComponent extends PositionComponent
    with TapCallbacks, HasGameReference, HasVisibility {
  final CardRun cardData;
  final bool enabled;
  final Function(CardRun) onCardPlayed;
  static const double cardWidth = 70.0;
  static const double cardHeight = 90.0;
  static const double cardSpacing = 8.0;
  static const double cardTopMargin = 40.0;
  static const int maxCards = 5;

  CardVisualComponent(
    this.cardData, {
    required Vector2 position,
    required Vector2 size,
    required this.onCardPlayed,
    this.enabled = true,
  }) : super(
          position: position,
          size: size,
        );

  @override
  void onTapDown(TapDownEvent event) {
    if (enabled) {
      onCardPlayed(cardData);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw card background
    final paint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );

    // Draw card border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      borderPaint,
    );

    // Draw card name
    final nameText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    nameText.render(
      canvas,
      cardData.name,
      Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
    );

    // Draw card cost
    final costText = TextPaint(
      style: const TextStyle(
        color: Colors.yellow,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    costText.render(
      canvas,
      '${cardData.cost}',
      Vector2(15, 15),
      anchor: Anchor.topLeft,
    );

    // Draw card value
    final valueText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    valueText.render(
      canvas,
      '${cardData.value}',
      Vector2(size.x / 2, size.y - 20),
      anchor: Anchor.bottomCenter,
    );

    // Draw card type
    final typeText = TextPaint(
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
      ),
    );
    typeText.render(
      canvas,
      cardData.type.toString().split('.').last.toUpperCase(),
      Vector2(size.x / 2, size.y - 5),
      anchor: Anchor.bottomCenter,
    );
  }

  Color _getCardColor() {
    switch (cardData.color.toLowerCase()) {
      case 'red':
        return Colors.red.shade900;
      case 'blue':
        return Colors.blue.shade900;
      case 'green':
        return Colors.green.shade900;
      case 'purple':
        return Colors.purple.shade900;
      case 'orange':
        return Colors.orange.shade900;
      default:
        return Colors.blue.shade900;
    }
  }
}
