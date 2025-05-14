import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class BallerinaCappuccina extends EnemyBase {
  BallerinaCappuccina() : super(
    name: 'Ballerina Cappuccina',
    maxHealth: 80,
    attack: 13,
    defense: 7,
    emoji: '🩰',
    color: Colors.pink,
    imagePath: 'ballerina_cappuccina.webp',
    soundPath: 'ballerina_cappuccina.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 70) {
      return const GameCard(
        name: 'Pirouette Strike',
        description: 'A spinning attack',
        type: CardType.attack,
        value: 12,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Graceful Heal',
        description: 'Heals with a graceful dance',
        type: CardType.heal,
        value: 7,
      );
    } else {
      return const GameCard(
        name: 'Dizzy Spin',
        description: 'Confuses the target with a fast spin',
        type: CardType.statusEffect,
        value: 4,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.2).round();
  }

  @override
  String get description => 'A graceful dancer whose pirouettes can dizzy and delight. Her elegance hides her strength.';
} 