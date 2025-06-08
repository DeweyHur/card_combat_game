import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class MainMenuScene extends BasePanel {
  MainMenuScene() : super(position: Vector2.zero(), size: Vector2(800, 600));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add title
    add(TextComponent(
      text: 'Card Combat',
      position: Vector2(size.x / 2, 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: material.TextStyle(
          fontSize: 48,
          color: material.Colors.white,
        ),
      ),
    ));

    // Add start button
    add(SimpleButtonComponent.text(
      text: 'Start Game',
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(200, 50),
      color: material.Colors.green,
      onPressed: () {
        final sceneManager = SceneManager();
        sceneManager.pushScene('map');
      },
    ));

    // Add quit button
    add(SimpleButtonComponent.text(
      text: 'Quit',
      position: Vector2(size.x / 2, size.y / 2 + 80),
      size: Vector2(200, 50),
      color: material.Colors.red,
      onPressed: () {
        // TODO: Implement quit functionality
      },
    ));
  }

  @override
  void updateUI() {
    // No updates needed
  }
}
