import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';

class TavernScene extends BaseScene {
  TavernScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.orange.shade100, options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add a simple label for now
    // You can add Flame/FCS components here if needed
  }
}
