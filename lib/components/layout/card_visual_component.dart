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
  final Function(GameCard) onCardPlayed;
  final bool enabled;

  CardVisualComponent(
    this.cardData, {
    required Vector2 position,
    required Vector2 size,
    required this.onCardPlayed,
    required this.enabled,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Card background with pixel art style
    final backgroundPaint = Paint()
      ..color = enabled ? BasicPalette.white.color : BasicPalette.gray.color
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
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
    );
    add(topLeftCorner);

    // Top-right corner
    final topRightCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize, 0),
      paint: cornerPaint,
    );
    add(topRightCorner);

    // Bottom-left corner
    final bottomLeftCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(0, size.y - cornerSize),
      paint: cornerPaint,
    );
    add(bottomLeftCorner);

    // Bottom-right corner
    final bottomRightCorner = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize, size.y - cornerSize),
      paint: cornerPaint,
    );
    add(bottomRightCorner);

    // Card Name with pixel art style
    final nameText = TextComponent(
      text: cardData.name,
      textRenderer: CardCombatGame.cardTextStyle,
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    // Card Type with pixel art style
    final typeText = TextComponent(
      text: cardData.type.toString().split('.').last.toUpperCase(),
      textRenderer: CardCombatGame.cardDescriptionStyle,
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
    );
    add(typeText);

    // Card Description with pixel art style
    final descText = TextComponent(
      text: cardData.description,
      textRenderer: CardCombatGame.cardDescriptionStyle,
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.bottomCenter,
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
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final game = findGame() as CardCombatGame;
    game.onCardTap(this);
  }

  @override
  bool onTapUp(TapUpEvent event) {
    return enabled;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    return enabled;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Debug rendering
    final debugPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw card boundary
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      debugPaint,
    );
  }
} 