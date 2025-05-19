import 'base_scene.dart';
import 'package:card_combat_app/components/panel/inventory_panel_container.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart' show Color;

class InventoryScene extends BaseScene {
  InventoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244), options: options);

  late List<EquipmentData> allEquipment;
  String? filter;
  GameCharacter? player;
  String? slot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Retrieve all equipment from DataController
    final equipmentMap = DataController.instance
            .get<Map<String, EquipmentData>>('equipmentData') ??
        {};
    allEquipment = equipmentMap.values.toList();
    filter = options?['slot'] as String?;
    player = options?['player'] as GameCharacter?;
    slot = filter;
    GameLogger.info(LogCategory.game,
        '[INVENTORY] Will add InventoryPanel in onMount: items=${allEquipment.length}, filter=$filter, player=${player?.name}, slot=$slot');
  }

  @override
  void onMount() {
    super.onMount();
    final container = InventoryPanelContainer(
      items: allEquipment,
      filter: filter,
      player: player,
      slot: slot,
      size: size,
    );
    add(container);
  }
}
