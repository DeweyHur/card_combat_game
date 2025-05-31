import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/simple_button_component.dart';

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
      paint: Paint()..color = Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));
    // Add title
    add(TextComponent(
      text: 'Inventory',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 20),
    ));
    // List items as buttons
    double y = 80;
    final filtered = items
        .where((item) =>
            filter == null ||
            item.handedness.toLowerCase() == filter?.toLowerCase() ||
            (filter == 'Chest' &&
                item.handedness.toLowerCase().contains('armor') == true) ||
            (filter == 'Head' &&
                item.handedness.toLowerCase().contains('helmet') == true) ||
            (filter == 'Pants' &&
                item.handedness.toLowerCase().contains('legs') == true) ||
            (filter == 'Shoes' &&
                item.handedness.toLowerCase().contains('boots') == true))
        .toList();

    GameLogger.info(LogCategory.game,
        '[INVENTORY] Filtered items: ${filtered.length} items for $filter');
    for (final item in filtered) {
      GameLogger.info(LogCategory.game,
          '[INVENTORY] Item: ${item.name} (${item.handedness})');
      add(SimpleButtonComponent.text(
        text: '${item.name} (${item.handedness})',
        size: Vector2(size.x - 48, 28),
        color: Colors.blueGrey.shade800,
        onPressed: () => onSelect(item),
        position: Vector2(24, y),
      ));
      y += 36;
    }
  }
}
