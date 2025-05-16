import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/equipment_panel.dart';

class ArmorySceneLayout extends PositionComponent {
  late final TextComponent _titleText;
  late final PositionComponent _backButton;
  bool _isLoaded = false;

  ArmorySceneLayout();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _titleText = TextComponent(
      text: 'Armory / Equipment',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    add(_titleText);

    // Add EquipmentPanel below the title
    final equipmentPanel = EquipmentPanel(size: Vector2(size.x, size.y * 0.28))
      ..position = Vector2(0, size.y * 0.32)
      ..anchor = Anchor.topLeft;
    add(equipmentPanel);

    _backButton = PositionComponent(
      size: Vector2(160, 48),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(160, 48),
        paint: Paint()..color = Colors.grey.shade800,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Back',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(80, 24),
        ),
      );
    add(_backButton);

    _isLoaded = true;
    _updatePositions(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isLoaded) {
      _updatePositions(size);
    }
  }

  void _updatePositions(Vector2 size) {
    _titleText.position = Vector2(size.x / 2, size.y * 0.25);
    _backButton.position = Vector2(size.x / 2, size.y * 0.8);
  }

  void handleTap(Vector2 pos) {
    if (_backButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('title');
    }
  }
} 