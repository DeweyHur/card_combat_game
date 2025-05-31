import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class TitleSceneLayout extends PositionComponent {
  late final TextComponent _titleText;
  late final SimpleButtonComponent _startButton;
  late final SimpleButtonComponent _exitButton;
  late final TextComponent _copyrightText;
  late final SimpleButtonComponent _armoryButton;
  late final SimpleButtonComponent _resumeButton;
  late final SimpleButtonComponent _creditButton;
  bool _isLoaded = false;

  TitleSceneLayout() : super(anchor: Anchor.topLeft);

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
      _resumeButton = SimpleButtonComponent.text(
        text: 'Resume',
        size: Vector2(200, 50),
        color: Colors.orange,
        onPressed: () {
          // TODO: Implement resume game logic
        },
        position: Vector2(size.x / 2, size.y * 0.42),
      );
      add(_resumeButton);
    }

    _startButton = SimpleButtonComponent.text(
      text: 'Game Start',
      size: Vector2(200, 50),
      color: Colors.green,
      onPressed: () {
        SceneManager().pushScene('player_selection');
      },
      position: Vector2(size.x / 2, size.y * 0.5),
    );
    add(_startButton);

    _armoryButton = SimpleButtonComponent.text(
      text: 'Armory',
      size: Vector2(200, 50),
      color: Colors.blue,
      onPressed: () {
        SceneManager().pushScene('equipment');
      },
      position: Vector2(size.x / 2, size.y * 0.62),
    );
    add(_armoryButton);

    _creditButton = SimpleButtonComponent.text(
      text: 'Credit',
      size: Vector2(200, 50),
      color: Colors.purple,
      onPressed: () {
        SceneManager().pushScene('credit');
      },
      position: Vector2(size.x / 2, size.y * 0.68),
    );
    add(_creditButton);

    _exitButton = SimpleButtonComponent.text(
      text: 'Exit',
      size: Vector2(200, 50),
      color: Colors.red,
      onPressed: () {
        exit(0);
      },
      position: Vector2(size.x / 2, size.y * 0.74),
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
      position: Vector2(size.x / 2, size.y - 10),
    );
    add(_copyrightText);

    _isLoaded = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isLoaded) {
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
  }
}
