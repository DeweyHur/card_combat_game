import 'package:flame/components.dart';
import 'package:card_combat_app/components/layout/inventory_scene_layout.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flutter/material.dart';

class InventoryScene extends BaseScene {
  late InventorySceneLayout layout;

  InventoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    layout = InventorySceneLayout(
      position: Vector2.zero(),
      size: size,
    );
    add(layout);
  }
}
