import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/models/game_card.dart';

class CardUpgradePanel extends PositionComponent {
  final GameCard card;
  final Function(GameCard) onUpgrade;
  final Function() onCancel;

  CardUpgradePanel({
    required this.card,
    required this.onUpgrade,
    required this.onCancel,
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

    // Add card name
    add(TextComponent(
      text: card.name,
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

    // Add upgrade button
    add(SimpleButtonComponent.text(
      text: 'Upgrade',
      size: Vector2(200, 50),
      color: material.Colors.green,
      onPressed: () => onUpgrade(card),
      position: Vector2(size.x / 2, size.y - 40),
    ));

    // Add cancel button
    add(SimpleButtonComponent.text(
      text: 'Cancel',
      size: Vector2(200, 50),
      color: material.Colors.red,
      onPressed: onCancel,
      position: Vector2(size.x / 2, size.y - 100),
    ));
  }
}
