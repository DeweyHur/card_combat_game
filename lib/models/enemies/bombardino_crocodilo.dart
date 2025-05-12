import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class BombardinoCrocodilo extends EnemyBase {
  BombardinoCrocodilo() : super(
    name: 'Bombardino Crocodilo',
    maxHealth: 95,
    attack: 16,
    defense: 5,
    emoji: '🐊',
    color: Colors.green,
    imagePath: 'characters/bombardino_crocodilo/bombardino_crocodilo.webp',
    soundPath: 'characters/bombardino_crocodilo/bombardino_crocodilo_italian_brainrot.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 70) {
      return GameCard(
        name: 'Tail Whip',
        description: 'Whips with a powerful tail',
        type: CardType.attack,
        value: 14,
      );
    } else if (random < 90) {
      return GameCard(
        name: 'Swamp Heal',
        description: 'Heals in the swamp',
        type: CardType.heal,
        value: 7,
      );
    } else {
      return GameCard(
        name: 'Croc Confusion',
        description: 'Confuses the target with a crocodile grin',
        type: CardType.statusEffect,
        value: 5,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.2).round();
  }
} 