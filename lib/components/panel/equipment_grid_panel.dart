import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class EquipmentGridPanel extends BasePanel {
  final void Function(EquipmentTemplate) onEquipmentSelected;
  List<SimpleButtonComponent> _itemButtons = [];
  String? _selectedType;
  Map<String, List<EquipmentTemplate>> _equipmentByType = {};

  // Map rarity to colors
  static const Map<String, Color> _rarityColors = {
    'common': Colors.white,
    'uncommon': Colors.green,
    'rare': Colors.blue,
    'epic': Colors.purple,
    'legendary': Colors.orange,
  };

  EquipmentGridPanel({
    required this.onEquipmentSelected,
  }) : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _loadEquipmentData();
  }

  void _loadEquipmentData() {
    final equipmentData = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
    if (equipmentData == null) {
      GameLogger.error(
          LogCategory.data, '[GRID] Failed to load equipment data');
      return;
    }

    _equipmentByType.clear();
    for (final equipment in equipmentData.values) {
      _equipmentByType.putIfAbsent(equipment.type, () => []).add(equipment);
    }

    // Sort equipment in each type by rarity
    for (final type in _equipmentByType.keys) {
      _equipmentByType[type]!.sort((a, b) {
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
    }

    updateUI();
  }

  void updateEquipmentType(String type) {
    _selectedType = type;
    updateUI();
  }

  void _updateUI() {
    // Clear existing buttons
    for (final button in _itemButtons) {
      button.removeFromParent();
    }
    _itemButtons.clear();

    // Reset vertical stack
    resetVerticalStack();

    // Add title
    final title = TextComponent(
      text: _selectedType ?? 'Select Equipment Type',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    registerVerticalStackComponent('title', title, 40);

    if (_selectedType == null) {
      return;
    }

    final equipmentList = _equipmentByType[_selectedType] ?? [];
    if (equipmentList.isEmpty) {
      final noItemsText = TextComponent(
        text: 'No equipment available for this type',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      registerVerticalStackComponent('noItems', noItemsText, 40);
      return;
    }

    // Calculate grid layout
    final itemsPerRow = 3;
    final itemWidth = (size.x - 40) / itemsPerRow;
    final itemHeight = 120.0;
    final padding = 10.0;

    // Create grid of equipment buttons
    for (int i = 0; i < equipmentList.length; i++) {
      final equipment = equipmentList[i];
      final row = i ~/ itemsPerRow;
      final col = i % itemsPerRow;
      final x = col * (itemWidth + padding) + padding;
      final y = row * (itemHeight + padding) + padding;

      final button = SimpleButtonComponent.text(
        text: '${equipment.name}\n${equipment.rarity}',
        size: Vector2(itemWidth, itemHeight),
        color: _rarityColors[equipment.rarity.toLowerCase()] ?? Colors.white,
        onPressed: () => onEquipmentSelected(equipment),
        position: Vector2(x, y),
      );
      add(button);
      _itemButtons.add(button);
    }
  }

  @override
  void updateUI() {
    _updateUI();
  }
}
