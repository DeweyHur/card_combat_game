import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class BrrBrrPatapim extends EnemyBase {
  BrrBrrPatapim() : super(
    name: 'Brr Brr Patapim',
    maxHealth: 100,
    attack: 17,
    defense: 9,
    emoji: '❄️',
    color: Colors.blue,
    imagePath: 'brr_brr_patapim.webp',
    soundPath: 'brr_brr_patapim.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 75) {
      return const GameCard(
        name: 'Frost Strike',
        description: 'A chilling attack',
        type: CardType.attack,
        value: 16,
      );
    } else if (random < 95) {
      return const GameCard(
        name: 'Icy Heal',
        description: 'Heals with icy winds',
        type: CardType.heal,
        value: 10,
      );
    } else {
      return const GameCard(
        name: 'Snow Confusion',
        description: 'Confuses the target with a snowstorm',
        type: CardType.statusEffect,
        value: 6,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 3,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.35).round();
  }

  @override
  String get description => 'A frosty foe who brings the chill of winter to every battle. His icy strikes are as cold as his heart.';
} 