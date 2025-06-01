import 'package:flame/components.dart';
import 'package:card_combat_app/components/layout/inventory_scene_layout.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flame/game.dart';

class InventoryScene extends BaseScene {
  late InventorySceneLayout layout;
  dynamic _player;
  String? _slot;

  InventoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Get the player and slot from the scene data
    _player = DataController.instance.getSceneData('inventory', 'player');
    _slot = DataController.instance.getSceneData('inventory', 'slot');

    if (_player == null || _slot == null) {
      GameLogger.error(
          LogCategory.game, '[INV_GRID] Missing player or slot data');
      return;
    }

    GameLogger.info(
        LogCategory.game, '[INV_GRID] Loading inventory for slot $_slot');
  }

  @override
  void onMount() {
    super.onMount();

    // Create the layout
    layout = InventorySceneLayout(
      position: Vector2.zero(),
      size: size,
    );
    add(layout);
  }
}
