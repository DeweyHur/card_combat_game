import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/equipment_scene_layout.dart';
import 'base_scene.dart';

class EquipmentScene extends BaseScene with TapCallbacks {
  late final EquipmentSceneLayout _layout;

  EquipmentScene() : super(sceneBackgroundColor: const Color(0xFF222244));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _layout = EquipmentSceneLayout();
    add(_layout);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout.onGameResize(size);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _layout.handleTap(event.canvasPosition);
  }
} 