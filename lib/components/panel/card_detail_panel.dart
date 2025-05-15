import 'package:flame/components.dart';
import 'package:flame/components.dart' show HasVisibility;
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';

class CardDetailPanel extends PositionComponent with HasVisibility {
  late TextComponent nameText;
  late TextComponent descText;
  late TextComponent typeText;
  late TextComponent valueText;
  late TextComponent costText;
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
    costText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      position: Vector2(120, 10),
      anchor: Anchor.topRight,
    );
    add(costText);
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
    costText.text = 'Cost: \u26A1${card.cost}';
    valueText.text = 'Value: ${card.value}';
    descText.text = card.description;
  }

  void showDeckAndDiscardInfo(int deckCount, int discardCount) {
    nameText.text = '';
    typeText.text = '';
    costText.text = '';
    valueText.text = '';
    descText.text = 'Deck: $deckCount  |  Discard: $discardCount';
  }
} 