import 'package:flame/components.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/inventory_grid_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flutter/material.dart';

class InventoryScene extends BaseScene {
  late InventoryGridPanel gridPanel;
  late EquipmentDetailPanel detailPanel;
  EquipmentData? selectedEquipment;
  late GameCharacter player;
  late String slot;

  InventoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    // Create grid panel
    gridPanel = InventoryGridPanel(
      onSelect: _handleItemSelect,
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y - 220),
    );
    add(gridPanel);

    // Create detail panel (initially hidden)
    detailPanel = EquipmentDetailPanel(
      equipment: DataController.instance
          .get<Map<String, EquipmentData>>('equipmentData')!
          .values
          .first,
      position: Vector2(0, size.y - 220),
      size: Vector2(size.x, 220),
    );
    detailPanel.removeFromParent();

    // If we're swapping equipment, select the currently equipped item
    final equippedItemName = player.equipment[slot];
    if (equippedItemName != null) {
      final equipmentMap = DataController.instance
          .get<Map<String, EquipmentData>>('equipmentData')!;
      final equippedItem = equipmentMap.values.firstWhere(
        (e) => e.name == equippedItemName,
        orElse: () => equipmentMap.values.first,
      );
      _handleItemSelect(equippedItem);
    }
  }

  void _handleItemSelect(EquipmentData item) {
    selectedEquipment = item;
    detailPanel.updateEquipment(item);
    if (!detailPanel.isMounted) {
      add(detailPanel);
    }
  }
}
