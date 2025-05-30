import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class CampEventScene extends BaseScene {
  CampEventScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.teal.shade100, options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CampEventPanel());
  }
}

class CampEventPanel extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TextComponent(
      text: 'Camp Event! (Placeholder)',
      position: Vector2(100, 100),
      textRenderer:
          TextPaint(style: const TextStyle(fontSize: 32, color: Colors.black)),
    ));
    add(ButtonComponent(
      label: 'Continue',
      onPressed: () => SceneManager().popScene(),
      position: Vector2(100, 200),
    ));
  }
}
