import 'base_scene.dart';
import 'package:card_combat_app/managers/dialogue_manager.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MapScene extends BaseScene {
  // All state variables from the widget, now as fields
  final DialogueManager _dialogueManager = DialogueManager();
  final SoundManager _soundManager = SoundManager();
  final bool _showBattleArea = false;

  double _playerX = 150;
  double _playerY = 150;
  final double _playerSize = 32;
  final double _moveSpeed = 3.0;

  late double _mapWidth;
  late double _mapHeight;

  final bool _isMovingUp = false;
  final bool _isMovingDown = false;
  final bool _isMovingLeft = false;
  final bool _isMovingRight = false;
  final double _crystalX = 0.0;
  final double _crystalY = 0.0;
  final double _crystalSize = 40;
  double _crystalGlow = 0;
  bool _crystalGlowIncreasing = true;
  bool _isAnimating = false;

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
    if (_isMovingUp) {
      _playerY = (_playerY - _moveSpeed).clamp(0, _mapHeight - _playerSize);
    }
    if (_isMovingDown) {
      _playerY = (_playerY + _moveSpeed).clamp(0, _mapHeight - _playerSize);
    }
    if (_isMovingLeft) {
      _playerX = (_playerX - _moveSpeed).clamp(0, _mapWidth - _playerSize);
    }
    if (_isMovingRight) {
      _playerX = (_playerX + _moveSpeed).clamp(0, _mapWidth - _playerSize);
    }
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
