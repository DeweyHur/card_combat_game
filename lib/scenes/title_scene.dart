import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'base_scene.dart';
import 'dart:io';

class TitleScene extends BaseScene with TapCallbacks {
  late final TextComponent _titleText;
  late final PositionComponent _startButton;
  late final PositionComponent _exitButton;
  late final TextComponent _copyrightText;

  TitleScene() : super(sceneBackgroundColor: const Color(0xFF1A1A2E));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _titleText = TextComponent(
      text: 'Card Combat',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2.zero(),
      anchor: Anchor.center,
    );
    add(_titleText);

    _startButton = PositionComponent(
      size: Vector2(200, 50),
      position: Vector2.zero(),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 50),
        paint: Paint()..color = Colors.green,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Game Start',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(100, 25),
        ),
      );
    add(_startButton);

    _exitButton = PositionComponent(
      size: Vector2(200, 50),
      position: Vector2.zero(),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 50),
        paint: Paint()..color = Colors.red,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Exit',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(100, 25),
        ),
      );
    add(_exitButton);

    _copyrightText = TextComponent(
      text: '© DewIn Studio',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2.zero(),
    );
    add(_copyrightText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _titleText.position = Vector2(size.x / 2, size.y * 0.25);
    _startButton.position = Vector2(size.x / 2, size.y * 0.5);
    _exitButton.position = Vector2(size.x / 2, size.y * 0.6);
    _copyrightText.position = Vector2(size.x / 2, size.y - 10);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final pos = event.canvasPosition;
    if (_startButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('player_selection');
    } else if (_exitButton.toRect().contains(pos.toOffset())) {
      exit(0);
    }
  }
} 