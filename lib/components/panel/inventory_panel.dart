import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:card_combat_app/models/equipment_loader.dart';

class InventoryPanel extends PositionComponent
    with HasGameReference, TapCallbacks {
  final List<EquipmentData> items;
  final String? filter;
  final void Function(EquipmentData) onSelect;

  InventoryPanel({
    required this.items,
    this.filter,
    required this.onSelect,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2(600, 400));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black54,
      anchor: Anchor.topLeft,
    ));
    // List items as buttons
    double y = 16;
    final filtered =
        items.where((item) => filter == null || item.slot == filter).toList();
    for (final item in filtered) {
      final button = ButtonComponent(
        button: RectangleComponent(
          size: Vector2(size.x - 48, 28),
          paint: Paint()..color = Colors.blueGrey.shade800,
          anchor: Anchor.topLeft,
          children: [
            TextComponent(
              text: '${item.name} (${item.slot})',
              textRenderer: TextPaint(
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              position: Vector2(8, 4),
              anchor: Anchor.topLeft,
            ),
          ],
        ),
        position: Vector2(24, y),
        anchor: Anchor.topLeft,
        onPressed: () => onSelect(item),
      );
      add(button);
      y += 36;
    }
  }
}
