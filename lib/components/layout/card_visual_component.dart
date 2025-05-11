import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CardVisualComponent extends PositionComponent with TapCallbacks {
  final GameCard cardData;
  final bool enabled;
  final Function(GameCard) onCardPlayed;

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

    // Log absolute position and size after component is loaded
    GameLogger.info(LogCategory.ui, 'CardVisualComponent loaded: ${cardData.name}');
    GameLogger.info(LogCategory.ui, '  - Position: ${position.x},${position.y}');
    GameLogger.info(LogCategory.ui, '  - Size: ${size.x}x${size.y}');
    GameLogger.info(LogCategory.ui, '  - Absolute Position: ${absolutePosition.x},${absolutePosition.y}');

    // Card background with pixel art style
    final backgroundPaint = Paint()
      ..color = enabled ? Colors.white : Colors.grey
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
      priority: 0, // Background should be at the bottom
    );
    add(cardBackground);

    // Card border with pixel art style
    final borderPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final cardBorder = RectangleComponent(
      size: size,
      paint: borderPaint,
      priority: 1, // Border above background
    );
    add(cardBorder);

    // Add pixel art corner decorations
    final cornerSize = 10.0;
    final cornerPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.fill;

    // Top-left corner
    final topLeftCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(0, 0),
      paint: cornerPaint,
      priority: 2, // Corners above border
    );
    add(topLeftCorner);

    // Top-right corner
    final topRightCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize, 0),
      paint: cornerPaint,
      priority: 2,
    );
    add(topRightCorner);

    // Bottom-left corner
    final bottomLeftCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(0, size.y - cornerSize),
      paint: cornerPaint,
      priority: 2,
    );
    add(bottomLeftCorner);

    // Bottom-right corner
    final bottomRightCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize, size.y - cornerSize),
      paint: cornerPaint,
      priority: 2,
    );
    add(bottomRightCorner);

    // Card Name with pixel art style
    final nameText = TextComponent(
      text: cardData.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      priority: 3, // Text above all decorative elements
    );
    add(nameText);

    // Card Type with pixel art style
    final typeText = TextComponent(
      text: cardData.type.toString().split('.').last.toUpperCase(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
      priority: 3,
    );
    // Add background rectangle for text
    final textBg = RectangleComponent(
      size: Vector2(120, 30),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill,
      priority: 2,
    );
    add(textBg);
    add(typeText);
    GameLogger.info(LogCategory.ui, 'Card type text positions:');
    GameLogger.info(LogCategory.ui, '  - Relative position: ${typeText.position.x},${typeText.position.y}');
    GameLogger.info(LogCategory.ui, '  - Absolute position: ${typeText.absolutePosition.x},${typeText.absolutePosition.y}');
    GameLogger.info(LogCategory.ui, '  - Z-index: ${typeText.priority}');

    // Card Description with pixel art style
    final descText = TextComponent(
      text: cardData.description,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.bottomCenter,
      priority: 3,
    );
    add(descText);

    // Card Value
    if (cardData.type == CardType.attack || cardData.type == CardType.heal) {
      final valueText = TextComponent(
        text: cardData.value.toString(),
        textRenderer: TextPaint(
          style: TextStyle(
            color: _getCardColor(),
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        priority: 3,
      );
      add(valueText);
    }

    GameLogger.info(LogCategory.ui, 'CardVisualComponent loaded: ${cardData.name} at position ${position.x},${position.y}');
  }

  @override
  void onMount() {
    super.onMount();
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
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (enabled) {
      onCardPlayed(cardData);
    }
  }

  @override
  bool onTapUp(TapUpEvent event) {
    return enabled;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    return enabled;
  }
} 