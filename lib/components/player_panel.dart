import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'base_panel.dart';

class PlayerPanel extends BasePanel {
  PlayerPanel(Vector2 gameSize) : super(
    gameSize: gameSize,
    characterEmoji: '🧙',
    hpColor: Colors.white,
    isTop: false,
  );
} 