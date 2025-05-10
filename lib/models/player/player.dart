import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class Player extends Character {
  Player({
    required String name,
    required int maxHealth,
  }) : super(name: name, maxHealth: maxHealth);

  // Player-specific methods can be added here
  // For example, leveling up, gaining experience, etc.
} 