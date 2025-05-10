import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'enemy_base.dart';

class Goblin extends EnemyBase {
  static const List<EnemyAction> _goblinActions = [
    EnemyAction(
      name: 'Slash',
      description: 'Slash for 5 damage',
      damage: 5,
    ),
    EnemyAction(
      name: 'Rage',
      description: 'Rage attack for 8 damage',
      damage: 8,
    ),
    EnemyAction(
      name: 'Scratch',
      description: 'Scratch for 3 damage',
      damage: 3,
    ),
  ];

  Goblin() : super(
    name: 'Goblin',
    emoji: '👹',
    maxHp: 20,
    color: const Color(0xFFE74C3C),
    possibleActions: _goblinActions,
  );
} 