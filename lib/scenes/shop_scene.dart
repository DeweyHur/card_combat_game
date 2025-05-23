import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';

class ShopScene extends BaseScene {
  ShopScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.yellow.shade100, options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add a simple label for now
    // You can add Flame/FCS components here if needed
  }
}
