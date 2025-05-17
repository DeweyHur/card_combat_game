import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_scene.dart';
import 'package:card_combat_app/components/layout/title_scene_layout.dart';

class TitleScene extends BaseScene with TapCallbacks {
  late final TitleSceneLayout _layout;

  TitleScene() : super(sceneBackgroundColor: const Color(0xFF1A1A2E));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _layout = TitleSceneLayout();
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
