import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class InventoryListPanel extends PositionComponent with VerticalStackMixin {
  final String slot;
  final void Function(EquipmentTemplate) onSelect;
  final List<SimpleButtonComponent> itemButtons = [];

  // Map equipment types to emojis
  static const Map<String, String> _typeEmojis = {
    'head': '⛑️',
    'chest': '🦺',
    'belt': '🧰',
    'pants': '👖',
    'shoes': '👢',
    'weapon': '⚔️',
    'offhand': '🛡️',
    'accessory 1': '💍',
    'accessory 2': '📿',
  };

  // Map rarity to colors
  static const Map<String, Color> _rarityColors = {
    'common': Colors.white,
    'uncommon': Colors.green,
    'rare': Colors.blue,
    'epic': Colors.purple,
    'legendary': Colors.orange,
  };

  InventoryListPanel({
    required this.slot,
    required this.onSelect,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateEquipmentList();
  }

  void _updateEquipmentList() async {
    // Clear existing buttons
    for (final button in itemButtons) {
      button.removeFromParent();
    }
    itemButtons.clear();

    resetVerticalStack();

    // Add title
    final title = TextComponent(
      text: 'Inventory',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    registerVerticalStackComponent('title', title, 40);

    // Get equipment data from DataController
    final equipmentData = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
    if (equipmentData == null) {
      GameLogger.error(LogCategory.data, 'Failed to load equipment data');
      return;
    }

    // Filter equipment by slot
    final slotEquipment = equipmentData.values
        .where(
            (equipment) => equipment.type.toLowerCase() == slot.toLowerCase())
        .toList();

    GameLogger.info(LogCategory.game,
        '[INV_LIST] Found ${slotEquipment.length} items for slot $slot');

    // Sort equipment by rarity
    final sortedItems = List<EquipmentTemplate>.from(slotEquipment);
    sortedItems.sort((a, b) {
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

    GameLogger.debug(LogCategory.game,
        '[INV_LIST] Found ${sortedItems.length} items to display');

    // Create list items
    for (int i = 0; i < sortedItems.length; i++) {
      final equipment = sortedItems[i];
      final emoji = _typeEmojis[equipment.type.toLowerCase()] ?? '❓';
      final rarityColor =
          _rarityColors[equipment.rarity.toLowerCase()] ?? Colors.white;

      // Create button with equipment info
      final button = SimpleButtonComponent.text(
        text: '$emoji ${equipment.name}\n${equipment.description}',
        size: Vector2(size.x - 48, 60),
        color: rarityColor.withOpacity(0.3),
        onPressed: () => onSelect(equipment),
        position: Vector2(24, 0),
      );
      registerVerticalStackComponent('item_$i', button, 60);
      itemButtons.add(button);
    }
  }
}
