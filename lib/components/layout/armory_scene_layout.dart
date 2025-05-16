import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/equipment_panel.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

class ArmorySceneLayout extends PositionComponent with VerticalStackMixin {
  late final TextComponent _titleText;
  late final PositionComponent _backButton;
  bool _isLoaded = false;

  ArmorySceneLayout();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();

    // Title
    _titleText = TextComponent(
      text: 'Armory / Equipment',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      size: Vector2(size.x, 50),
    );
    addToVerticalStack(_titleText, 50);

    // Equipment Panel
    final equipmentPanel = EquipmentPanel(size: Vector2(size.x, size.y * 0.28));
    addToVerticalStack(equipmentPanel, size.y * 0.28);

    // Back Button
    _backButton = PositionComponent(
      size: Vector2(160, 48),
      anchor: Anchor.topCenter,
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
    addToVerticalStack(_backButton, 60);

    _isLoaded = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    // Optionally, you could re-layout children here if dynamic resizing is needed
  }

  void handleTap(Vector2 pos) {
    if (_backButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('title');
    }
  }
} 