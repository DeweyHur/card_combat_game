import 'base_scene.dart';
import 'package:card_combat_app/managers/dialogue_manager.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'package:card_combat_app/components/nintendo_message_box.dart';
import 'package:flutter/material.dart'
    show Color, Colors, Icon, Icons, TextStyle;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';
import 'dart:ui';

class MapScene extends BaseScene with TapCallbacks {
  // All state variables from the widget, now as fields
  final DialogueManager _dialogueManager = DialogueManager();
  final SoundManager _soundManager = SoundManager();
  bool _showDialogue = true;
  bool _showBattleArea = false;
  bool _isInitialized = false;

  double _playerX = 150;
  double _playerY = 150;
  final double _playerSize = 32;
  final double _moveSpeed = 3.0;

  late double _mapWidth;
  late double _mapHeight;

  bool _isMovingUp = false;
  bool _isMovingDown = false;
  bool _isMovingLeft = false;
  bool _isMovingRight = false;
  double _crystalX = 0;
  double _crystalY = 0;
  final double _crystalSize = 40;
  double _crystalGlow = 0;
  bool _crystalGlowIncreasing = true;
  bool _isAnimating = false;

  final List<MapLandmark> _landmarks = [
    MapLandmark(
        name: "Borobudur Temple",
        x: 200,
        y: 150,
        type: LandmarkType.temple,
        color: Colors.brown),
    MapLandmark(
        name: "Mount Bromo",
        x: 300,
        y: 180,
        type: LandmarkType.mountain,
        color: Colors.grey),
    MapLandmark(
        name: "Bali Beach",
        x: 400,
        y: 250,
        type: LandmarkType.beach,
        color: Colors.blue),
    MapLandmark(
        name: "Komodo Island",
        x: 500,
        y: 280,
        type: LandmarkType.island,
        color: Colors.green),
    MapLandmark(
        name: "Raja Ampat",
        x: 600,
        y: 150,
        type: LandmarkType.beach,
        color: Colors.cyan),
  ];

  MapScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF87CEEB), options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _mapWidth = size.x;
    _mapHeight = size.y;
    await _soundManager.initialize();
    await _dialogueManager.loadDialogue('tutorial');
    _dialogueManager.startDialogue('tutorial');
    _startCrystalAnimation();
    _isInitialized = true;
  }

  void _startCrystalAnimation() {
    _isAnimating = true;
    // Use Flame's update loop for animation
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isAnimating) {
      if (_crystalGlowIncreasing) {
        _crystalGlow += 0.05;
        if (_crystalGlow >= 1) _crystalGlowIncreasing = false;
      } else {
        _crystalGlow -= 0.05;
        if (_crystalGlow <= 0) _crystalGlowIncreasing = true;
      }
    }
    if (_isMovingUp)
      _playerY = (_playerY - _moveSpeed).clamp(0, _mapHeight - _playerSize);
    if (_isMovingDown)
      _playerY = (_playerY + _moveSpeed).clamp(0, _mapHeight - _playerSize);
    if (_isMovingLeft)
      _playerX = (_playerX - _moveSpeed).clamp(0, _mapWidth - _playerSize);
    if (_isMovingRight)
      _playerX = (_playerX + _moveSpeed).clamp(0, _mapWidth - _playerSize);
    // Check for battle area
    if (_showBattleArea) {
      final dx = _playerX - _crystalX;
      final dy = _playerY - _crystalY;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance < (_playerSize + _crystalSize) / 2) {
        // TODO: Move to battle scene
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw map background, islands, landmarks, player, crystal, etc.
    // (You can move the CustomPainter logic here as needed)
  }

  // Add input handling for movement, dialogue, etc.
}

enum LandmarkType {
  temple,
  mountain,
  beach,
  island,
}

class MapLandmark {
  final String name;
  final double x;
  final double y;
  final LandmarkType type;
  final Color color;

  MapLandmark(
      {required this.name,
      required this.x,
      required this.y,
      required this.type,
      required this.color});
}
