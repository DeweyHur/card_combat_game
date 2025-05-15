import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:card_combat_app/models/game_card.dart';

class CardVisualComponent extends PositionComponent with TapCallbacks, HasGameRef, HasVisibility {
  final GameCard cardData;
  final bool enabled;
  final Function(GameCard) onCardPlayed;
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
  Future<void> onLoad() async {
    await super.onLoad();

    // Card background
    final backgroundPaint = Paint()
      ..color = enabled ? Colors.white : Colors.grey
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
      priority: 0,
    );
    add(cardBackground);

    // Card border
    final borderPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final cardBorder = RectangleComponent(
      size: size,
      paint: borderPaint,
      priority: 1,
    );
    add(cardBorder);

    // Card cost (top left)
    final costText = TextComponent(
      text: '⚡${cardData.cost}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(8, 8),
      anchor: Anchor.topLeft,
      priority: 2,
    );
    add(costText);

    // Large emoji in the center
    final emoji = _getCardEmoji();
    final emojiText = TextComponent(
      text: emoji,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2 - 8),
      anchor: Anchor.center,
      priority: 2,
    );
    add(emojiText);

    // Card value (bottom right)
    if (cardData.type == CardType.attack || cardData.type == CardType.heal || cardData.type == CardType.shield) {
      final valueText = TextComponent(
        text: cardData.value.toString(),
        textRenderer: TextPaint(
          style: TextStyle(
            color: _getCardColor(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x - 8, size.y - 8),
        anchor: Anchor.bottomRight,
        priority: 3,
      );
      add(valueText);
    }
  }

  Color _getCardColor() {
    switch (cardData.type) {
      case CardType.attack:
        return Colors.red;
      case CardType.heal:
        return Colors.green;
      case CardType.statusEffect:
        return Colors.purple;
      case CardType.cure:
        return Colors.blue;
      case CardType.shield:
        return Colors.blueGrey;
      case CardType.shieldAttack:
        return Colors.amber;
    }
  }

  String _getCardEmoji() {
    switch (cardData.type) {
      case CardType.attack:
        return '💥';
      case CardType.heal:
        return '💚';
      case CardType.statusEffect:
        return '🌀';
      case CardType.cure:
        return '✨';
      case CardType.shield:
        return '🛡️';
      case CardType.shieldAttack:
        return '🔰';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (enabled) {
      onCardPlayed(cardData);
    }
  }
} 