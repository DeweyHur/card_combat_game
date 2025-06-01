import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';

class InventoryGridCell extends PositionComponent with TapCallbacks {
  final EquipmentData equipment;
  final bool isEquipped;
  final VoidCallback onTap;

  // Map equipment types to emojis
  static const Map<String, String> _typeEmojis = {
    'weapon': '⚔️',
    'armor': '🛡️',
    'head': '⛑️',
    'boots': '👢',
    'gloves': '🧤',
    'ring': '💍',
    'amulet': '📿',
    'shield': '🛡️',
    'accessory': '✨',
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

    // Add cell background
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = isEquipped
            ? Colors.blueAccent.withAlpha(217)
            : Colors.white.withAlpha(32),
      anchor: Anchor.topLeft,
    ));

    // Add emoji icon
    final emoji = _typeEmojis[equipment.type.toLowerCase()] ?? '❓';
    add(TextComponent(
      text: emoji,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 10),
    ));

    // Add equipment name
    add(TextComponent(
      text: equipment.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 + 15),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
