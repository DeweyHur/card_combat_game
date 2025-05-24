import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class TitleSceneLayout extends PositionComponent {
  late final TextComponent _titleText;
  late final PositionComponent _startButton;
  late final PositionComponent _exitButton;
  late final TextComponent _copyrightText;
  late final PositionComponent _armoryButton;
  late final PositionComponent _resumeButton;
  late final PositionComponent _creditButton;
  bool _isLoaded = false;

  TitleSceneLayout();

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
      anchor: Anchor.center,
    );
    add(_titleText);

    // Check for saved game
    final prefs = await SharedPreferences.getInstance();
    final hasSave = prefs.getString('selectedPlayerName') != null;
    if (hasSave) {
      _resumeButton = PositionComponent(
        size: Vector2(200, 50),
        anchor: Anchor.center,
      )
        ..add(RectangleComponent(
          size: Vector2(200, 50),
          paint: Paint()..color = Colors.orange,
          anchor: Anchor.topLeft,
        ))
        ..add(
          TextComponent(
            text: 'Resume',
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
      add(_resumeButton);
    }

    _startButton = PositionComponent(
      size: Vector2(200, 50),
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

    _armoryButton = PositionComponent(
      size: Vector2(200, 50),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 50),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Armory',
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
    add(_armoryButton);

    _creditButton = PositionComponent(
      size: Vector2(200, 50),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 50),
        paint: Paint()..color = Colors.purple,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Credit',
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
    add(_creditButton);

    _exitButton = PositionComponent(
      size: Vector2(200, 50),
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
          color: Colors.white.withAlpha(128),
          fontSize: 14,
        ),
      ),
      anchor: Anchor.bottomCenter,
    );
    add(_copyrightText);

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
    _titleText.position = Vector2(size.x / 2, size.y * 0.22);
    double y = size.y * 0.42;
    if (children.contains(_resumeButton)) {
      _resumeButton.position = Vector2(size.x / 2, y);
      y += size.y * 0.08;
    }
    _startButton.position = Vector2(size.x / 2, y);
    _armoryButton.position = Vector2(size.x / 2, y + size.y * 0.12);
    _creditButton.position = Vector2(size.x / 2, y + size.y * 0.18);
    _exitButton.position = Vector2(size.x / 2, y + size.y * 0.24);
    _copyrightText.position = Vector2(size.x / 2, size.y - 10);
  }

  void handleTap(Vector2 pos) {
    if (children.contains(_resumeButton) &&
        _resumeButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('outpost');
    } else if (_startButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('player_selection');
    } else if (_armoryButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('equipment');
    } else if (_creditButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('credit');
    } else if (_exitButton.toRect().contains(pos.toOffset())) {
      exit(0);
    }
  }
}
