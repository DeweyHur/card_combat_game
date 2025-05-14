import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class BobombiniGoosini extends EnemyBase {
  BobombiniGoosini() : super(
    name: 'Bobombini Goosini',
    maxHealth: 75,
    attack: 14,
    defense: 7,
    emoji: '💣',
    color: Colors.red,
    imagePath: 'bobombini_goosini.webp',
    soundPath: 'bobombini_goosini_italian_brainrot.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 65) {
      return const GameCard(
        name: 'Bomb Toss',
        description: 'Throws a bomb at the target',
        type: CardType.attack,
        value: 13,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Fuse Heal',
        description: 'Heals by lighting a fuse',
        type: CardType.heal,
        value: 7,
      );
    } else {
      return const GameCard(
        name: 'Smoke Screen',
        description: 'Confuses the target with smoke',
        type: CardType.statusEffect,
        value: 3,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.25).round();
  }

  @override
  String get description => 'A bombastic troublemaker who loves explosions and chaos. Watch out for the smoke!';
} 