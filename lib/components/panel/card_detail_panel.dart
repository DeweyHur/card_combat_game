import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';

class CardDetailPanel extends PositionComponent with HasVisibility {
  late TextComponent nameText;
  late TextComponent descText;
  late TextComponent typeText;
  late TextComponent valueText;
  late RectangleComponent background;

  CardDetailPanel({Vector2? position, Vector2? size}) : super(position: position ?? Vector2.zero(), size: size ?? Vector2(180, 120));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.85),
    );
    add(background);
    nameText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
    );
    add(nameText);
    typeText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      position: Vector2(10, 36),
      anchor: Anchor.topLeft,
    );
    add(typeText);
    valueText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      position: Vector2(10, 56),
      anchor: Anchor.topLeft,
    );
    add(valueText);
    descText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      position: Vector2(10, 80),
      anchor: Anchor.topLeft,
    );
    add(descText);
  }

  void setCard(GameCard card) {
    nameText.text = card.name;
    typeText.text = card.type.toString().split('.').last.toUpperCase();
    valueText.text = 'Value: ${card.value}';
    descText.text = card.description;
  }
} 