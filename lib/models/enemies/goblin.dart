import 'package:flutter/material.dart';
import '../game_card.dart';
import 'enemy_base.dart';
import '../../utils/game_logger.dart';

class Goblin extends EnemyBase {
  Goblin() : super(
    name: 'Goblin',
    emoji: '👺',
    maxHp: 30,
    color: Colors.green,
  );

  @override
  GameCard getNextAction() {
    // Simple AI: 70% chance to attack, 20% chance to heal, 10% chance to apply status effect
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 70) {
      // Attack
      return GameCard(
        name: 'Goblin Strike',
        description: 'A quick attack',
        type: CardType.attack,
        value: 8,
      );
    } else if (random < 90) {
      // Heal
      return GameCard(
        name: 'Goblin Healing',
        description: 'Heals the goblin',
        type: CardType.heal,
        value: 5,
      );
    } else {
      // Status effect
      return GameCard(
        name: 'Goblin Poison',
        description: 'Poisons the target',
        type: CardType.statusEffect,
        value: 3,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 3,
      );
    }
  }
} 