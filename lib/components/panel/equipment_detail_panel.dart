import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';

class EquipmentDetailPanel extends PositionComponent {
  EquipmentData equipment;
  final VoidCallback? onChange;
  final VoidCallback? onUnequip;

  EquipmentDetailPanel({
    required this.equipment,
    this.onChange,
    this.onUnequip,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2(400, 220));

  void updateEquipment(EquipmentData newEquipment) {
    equipment = newEquipment;
    // Optionally, trigger a UI update if needed
    // (e.g., remove all children and call onLoad again, or update text components)
  }

  String getSlotDisplayName(String slot) {
    if (slot == 'Accessory 1') return 'Acc 1';
    if (slot == 'Accessory 2') return 'Acc 2';
    return slot;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add a background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.85),
      anchor: Anchor.topLeft,
    ));
    // Equipment name
    add(TextComponent(
      text: equipment.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(16, 16),
    ));
    // Equipment type
    add(TextComponent(
      text: 'Type: ${equipment.type}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(16, 48),
    ));
    // Equipment slot
    add(TextComponent(
      text: 'Slot: ${getSlotDisplayName(equipment.slot)}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(16, 72),
    ));
    // Handedness
    add(TextComponent(
      text: 'Handedness: ${equipment.handedness}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(16, 96),
    ));
    // Cards (if any)
    if (equipment.cards.isNotEmpty) {
      double y = 120;
      add(TextComponent(
        text: 'Cards:',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.topLeft,
        position: Vector2(16, y),
      ));
      y += 22;
      for (final card in equipment.cards) {
        add(TextComponent(
          text: card,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 14,
            ),
          ),
          anchor: Anchor.topLeft,
          position: Vector2(32, y),
        ));
        y += 20;
      }
    }
    // Action buttons (right side)
    add(_ButtonComponent(
      label: 'Change Equipment',
      onPressed: onChange,
      position: Vector2(size.x - 160, 32),
    ));
    add(_ButtonComponent(
      label: 'Unequip',
      onPressed: onUnequip,
      position: Vector2(size.x - 160, 80),
      color: Colors.redAccent,
    ));
  }
}

class _ButtonComponent extends PositionComponent {
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  _ButtonComponent({
    required this.label,
    this.onPressed,
    Vector2? position,
    this.color = Colors.blueAccent,
  }) : super(position: position, size: Vector2(140, 36));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color.withOpacity(0.85),
      anchor: Anchor.topLeft,
    ));
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call();
  }
} 