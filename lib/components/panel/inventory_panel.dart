import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class InventoryPanel extends BasePanel {
  final String? filter;
  final List<SimpleButtonComponent> itemButtons = [];

  InventoryPanel({
    Vector2? size,
    this.filter,
  }) : super(size: size);

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

    final equipmentMap = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
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
      final button = SimpleButtonComponent.text(
        text: equipment.name,
        size: Vector2(size.x - 40, 50),
        color: Colors.blue,
        onPressed: () {
          DataController.instance.set('selectedEquipmentName', equipment.name);
        },
        position: Vector2(20, y),
      );
      add(button);
      itemButtons.add(button);
      y += 60;
    }

    // Add back button at the bottom
    add(SimpleButtonComponent.text(
      text: 'Back',
      size: Vector2(200, 50),
      color: Colors.blue,
      onPressed: () {
        SceneManager().popScene();
      },
      position: Vector2(size.x / 2, size.y - 40),
    ));
  }

  @override
  void updateUI() {
    _updateEquipmentList();
  }
}
