import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../game/card_combat_game.dart';

class CardVisualComponent extends PositionComponent with TapCallbacks {
  final Card cardData;
  final Function(Card) onCardPlayed;
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

    // Card background
    final backgroundPaint = Paint()
      ..color = enabled ? BasicPalette.white.color : BasicPalette.gray.color
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
    );
    add(cardBackground);

    // Card border
    final borderPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final cardBorder = RectangleComponent(
      size: size,
      paint: borderPaint,
    );
    add(cardBorder);

    // Card Name
    final nameText = TextComponent(
      text: cardData.name,
      textRenderer: CardCombatGame.cardTextStyle,
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    // Card Type
    final typeText = TextComponent(
      text: cardData.type.toString().split('.').last.toUpperCase(),
      textRenderer: CardCombatGame.cardDescriptionStyle,
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
    );
    add(typeText);

    // Card Description
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
    if (!enabled) {
      print('Card is disabled, ignoring tap');
      return;
    }
    print('Card tapped: ${cardData.name} (${cardData.type})');
    onCardPlayed(cardData);
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