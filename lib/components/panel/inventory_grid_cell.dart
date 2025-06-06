import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class InventoryGridCell extends PositionComponent with TapCallbacks {
  final EquipmentTemplate equipment;
  final bool isEquipped;
  final VoidCallback onTap;

  // Map equipment types to emojis
  static const Map<String, String> _typeEmojis = {
    'weapon': '⚔️',
    'armor': '🛡️',
    'head': '⛑️',
    'helmet': '⛑️',
    'hat': '🎩',
    'chest': '🦺',
    'robe': '👘',
    'pants': '👖',
    'leggings': '👖',
    'shoes': '👢',
    'boots': '👢',
    'gauntlets': '🧤',
    'gloves': '🧤',
    'ring': '💍',
    'amulet': '📿',
    'shield': '🛡️',
    'accessory': '✨',
    'charm': '✨',
    'manual': '📖',
  };

  InventoryGridCell({
    required this.equipment,
    required this.isEquipped,
    required this.onTap,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = isEquipped
            ? Colors.green.withAlpha(77)
            : Colors.black.withAlpha(77),
    ));

    // Border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withAlpha(77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    ));

    // Equipment name
    add(TextComponent(
      text: equipment.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
    ));

    // Equipment type
    add(TextComponent(
      text: equipment.type,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.5),
      anchor: Anchor.center,
    ));

    // Equipment rarity
    add(TextComponent(
      text: equipment.rarity,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.7),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
