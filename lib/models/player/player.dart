import 'package:flutter/material.dart';
import '../game_card.dart';
import '../character.dart';
import '../../utils/game_logger.dart';

class Player extends Character {
  Player({
    required String name,
    required int maxHealth,
  }) : super(name: name, maxHealth: maxHealth);

  // Player-specific methods can be added here
  // For example, leveling up, gaining experience, etc.
} 