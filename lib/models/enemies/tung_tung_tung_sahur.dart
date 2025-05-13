import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class TungTungTungSahur extends EnemyBase {
  TungTungTungSahur() : super(
    name: 'Tung Tung Tung Sahur',
    maxHealth: 80,
    attack: 12,
    defense: 8,
    emoji: '🥁',
    color: Colors.brown,
    imagePath: 'tung_tung_tung_sahur.jpg',
    soundPath: 'tung_tung_tung_sahur.mp3',
  );

  @override
  GameCard selectAction() {
    // Simple AI: 60% chance to attack, 30% chance to heal, 10% chance to apply status effect
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 60) {
      return GameCard(
        name: 'Drum Strike',
        description: 'A powerful drum attack',
        type: CardType.attack,
        value: 10,
      );
    } else if (random < 90) {
      return GameCard(
        name: 'Rhythm Healing',
        description: 'Heals through the power of rhythm',
        type: CardType.heal,
        value: 8,
      );
    } else {
      return GameCard(
        name: 'Dizzy Beat',
        description: 'Confuses the target with complex rhythms',
        type: CardType.statusEffect,
        value: 3,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.2).round(); // 20% more damage due to drum power
  }
} 