import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flutter/material.dart';

class EquipmentPanel extends BasePanel {
  EquipmentPanel({Vector2? size}) : super(size: size);

  static const List<String> mainSlots = [
    'Head', 'Chest', 'Pants', 'Left Hand', 'Right Hand', 'Shoes'
  ];
  static const List<String> accessorySlots = [
    'Accessory 1', 'Accessory 2', 'Accessory 3', 'Accessory 4'
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final double slotWidth = size.x / 6.5;
    final double slotHeight = size.y * 0.32;
    final double spacing = size.x * 0.02;
    final double accessorySlotWidth = size.x / 5.5;
    final double accessorySlotHeight = size.y * 0.22;

    // Main slots row
    for (int i = 0; i < mainSlots.length; i++) {
      final slot = _buildSlot(
        mainSlots[i],
        Vector2(
          spacing + i * (slotWidth + spacing),
          size.y * 0.08,
        ),
        Vector2(slotWidth, slotHeight),
      );
      add(slot);
    }

    // Accessory slots row
    for (int i = 0; i < accessorySlots.length; i++) {
      final slot = _buildSlot(
        accessorySlots[i],
        Vector2(
          spacing + i * (accessorySlotWidth + spacing),
          size.y * 0.08 + slotHeight + size.y * 0.10,
        ),
        Vector2(accessorySlotWidth, accessorySlotHeight),
      );
      add(slot);
    }
  }

  PositionComponent _buildSlot(String label, Vector2 position, Vector2 size) {
    final slot = PositionComponent(
      position: position,
      size: size,
      anchor: Anchor.topLeft,
    );
    slot.add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withOpacity(0.4),
      anchor: Anchor.topLeft,
    ));
    slot.add(
      TextComponent(
        text: label,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );
    return slot;
  }

  @override
  void updateUI() {
    // Update equipment UI if needed
  }
} 