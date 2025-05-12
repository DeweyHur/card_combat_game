import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class TrullimeroTrullicina extends EnemyBase {
  TrullimeroTrullicina() : super(
    name: 'Trullimero Trullicina',
    maxHealth: 90,
    attack: 15,
    defense: 6,
    emoji: '🎭',
    color: Colors.purple,
    imagePath: 'characters/tru/tru.jpg',
    soundPath: 'characters/tru/tru.mp3',
  );

  @override
  GameCard selectAction() {
    // Simple AI: 70% chance to attack, 20% chance to heal, 10% chance to apply status effect
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 70) {
      return GameCard(
        name: 'Comedy Strike',
        description: 'A joke that hurts',
        type: CardType.attack,
        value: 12,
      );
    } else if (random < 90) {
      return GameCard(
        name: 'Laughing Heal',
        description: 'Heals through laughter',
        type: CardType.heal,
        value: 6,
      );
    } else {
      return GameCard(
        name: 'Confusing Joke',
        description: 'Confuses the target with a complex joke',
        type: CardType.statusEffect,
        value: 4,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 3,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.3).round(); // 30% more damage due to comedic timing
  }
} 