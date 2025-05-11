import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class Goblin extends EnemyBase {
  Goblin() : super(
    name: 'Goblin',
    maxHealth: 50,
    attack: 10,
    defense: 5,
    emoji: '👺',
    color: Colors.green,
  );

  @override
  GameCard selectAction() {
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

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 0.8).round(); // Goblin deals 20% less damage
  }
} 