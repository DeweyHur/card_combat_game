import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class BobriniCocococini extends EnemyBase {
  BobriniCocococini() : super(
    name: 'Bobrini Cocococini',
    maxHealth: 85,
    attack: 13,
    defense: 8,
    emoji: '🥥',
    color: Colors.brown,
    imagePath: 'bobrini_cocococini.png',
    soundPath: 'bobrini_cocococini.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 60) {
      return const GameCard(
        name: 'Coconut Smash',
        description: 'Hits with a coconut',
        type: CardType.attack,
        value: 11,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Coconut Water',
        description: 'Heals with coconut water',
        type: CardType.heal,
        value: 8,
      );
    } else {
      return const GameCard(
        name: 'Slippery Shell',
        description: 'Confuses the target with a slippery shell',
        type: CardType.statusEffect,
        value: 4,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.15).round();
  }

  @override
  String get description => 'A coconut-wielding wild one, smashing and splashing with tropical chaos.';
} 