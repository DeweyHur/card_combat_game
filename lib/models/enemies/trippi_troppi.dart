import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class TrippiTroppi extends EnemyBase {
  TrippiTroppi() : super(
    name: 'Trippi Troppi',
    maxHealth: 70,
    attack: 18,
    defense: 4,
    emoji: '🎪',
    color: Colors.orange,
    imagePath: 'characters/trippi troppi/trippi troppi.jpg',
    soundPath: 'characters/trippi troppi/trippi troppi.mp3',
  );

  @override
  GameCard selectAction() {
    // Simple AI: 80% chance to attack, 15% chance to heal, 5% chance to apply status effect
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 80) {
      return GameCard(
        name: 'Acrobatic Strike',
        description: 'A flip that hurts',
        type: CardType.attack,
        value: 15,
      );
    } else if (random < 95) {
      return GameCard(
        name: 'Tumbling Heal',
        description: 'Heals through acrobatics',
        type: CardType.heal,
        value: 5,
      );
    } else {
      return GameCard(
        name: 'Dizzy Flip',
        description: 'Confuses the target with complex flips',
        type: CardType.statusEffect,
        value: 5,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.4).round(); // 40% more damage due to acrobatic momentum
  }
} 