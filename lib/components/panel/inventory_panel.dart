import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class InventoryPanel extends PositionComponent
    with HasGameReference, TapCallbacks {
  final List<EquipmentData> items;
  final String? filter;
  final void Function(EquipmentData) onSelect;
  final List<SimpleButtonComponent> itemButtons = [];

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
    _updateEquipmentList();
  }

  void _updateEquipmentList() {
    // Clear existing buttons
    for (final button in itemButtons) {
      button.removeFromParent();
    }
    itemButtons.clear();

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

    final equipmentMap =
        DataController.instance.get<Map<String, EquipmentData>>('equipment');
    if (equipmentMap == null) {
      GameLogger.error(LogCategory.game, '[INVENTORY] No equipment data found');
      return;
    }

    // Filter equipment by type
    final filteredEquipment = equipmentMap.values.where((equipment) {
      if (filter == null) return true;
      return equipment.type.toLowerCase() == filter?.toLowerCase();
    }).toList();

    // Sort equipment by rarity
    filteredEquipment.sort((a, b) {
      final rarityOrder = {
        'common': 0,
        'uncommon': 1,
        'rare': 2,
        'epic': 3,
        'legendary': 4,
      };
      final aRarity = rarityOrder[a.rarity.toLowerCase()] ?? 0;
      final bRarity = rarityOrder[b.rarity.toLowerCase()] ?? 0;
      return bRarity.compareTo(aRarity);
    });

    // Create buttons for each equipment
    double y = 80;
    for (final equipment in filteredEquipment) {
      GameLogger.info(LogCategory.game,
          '[INVENTORY] Item: ${equipment.name} (${equipment.type})');
      final button = SimpleButtonComponent.text(
        text: '${equipment.name} (${equipment.rarity})',
        size: Vector2(size.x - 48, 28),
        color: Colors.blueGrey.shade800,
        onPressed: () => onSelect(equipment),
        position: Vector2(24, y),
      );
      itemButtons.add(button);
      add(button);
      y += 36;
    }
  }
}
