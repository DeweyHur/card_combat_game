import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/components/panel/inventory_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:flutter/material.dart' as material;

class InventoryScene extends BaseScene with HasGameRef {
  late final InventoryPanel _inventoryPanel;
  late final EquipmentDetailPanel _detailPanel;
  String? _selectedEquipmentName;
  Function(dynamic)? _equipmentWatcher;

  InventoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const material.Color(0xFF222244));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load player data
    final player = DataController.instance.get<PlayerRun>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[INVENTORY] No player selected');
      return;
    }

    // Create inventory panel
    _inventoryPanel = InventoryPanel(
      size: Vector2(300, gameRef.size.y),
      filter: null,
    );
    _inventoryPanel.position = Vector2(0, 0);
    add(_inventoryPanel);

    // Create detail panel
    _detailPanel = EquipmentDetailPanel();
    _detailPanel.position = Vector2(300, 0);
    _detailPanel.size = Vector2(gameRef.size.x - 300, gameRef.size.y);
    add(_detailPanel);

    // Listen for equipment selection
    _equipmentWatcher = (name) {
      if (name != null) {
        _selectedEquipmentName = name as String;
        _updateDetailPanel();
      }
    };
    DataController.instance.watch('selectedEquipmentName', _equipmentWatcher!);
  }

  void _updateDetailPanel() {
    if (_selectedEquipmentName == null) return;

    final equipmentMap = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
    if (equipmentMap == null) {
      GameLogger.error(LogCategory.game, '[INVENTORY] No equipment data found');
      return;
    }

    final equipment = equipmentMap[_selectedEquipmentName];
    if (equipment == null) {
      GameLogger.error(LogCategory.game,
          '[INVENTORY] Equipment not found: $_selectedEquipmentName');
      return;
    }

    _detailPanel.updateEquipment(equipment);
  }

  @override
  void onRemove() {
    if (_equipmentWatcher != null) {
      DataController.instance
          .unwatch('selectedEquipmentName', _equipmentWatcher!);
    }
    super.onRemove();
  }
}
