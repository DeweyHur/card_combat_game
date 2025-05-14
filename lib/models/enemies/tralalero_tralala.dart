import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:flutter/material.dart';

class TralaleroTralala extends EnemyBase {
  TralaleroTralala() : super(
    name: 'Tralalero Tralala',
    maxHealth: 75,
    attack: 11,
    defense: 9,
    emoji: '🎤',
    color: Colors.purpleAccent,
    imagePath: 'tralalero_tralala.webp',
    soundPath: 'tralalero_tralala_italian_brainrot_u3ai6wj.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 60) {
      return const GameCard(
        name: 'Singing Strike',
        description: 'A powerful vocal attack',
        type: CardType.attack,
        value: 10,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Melodic Heal',
        description: 'Heals with a soothing melody',
        type: CardType.heal,
        value: 8,
      );
    } else {
      return const GameCard(
        name: 'Discordant Note',
        description: 'Confuses the target with a discordant note',
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
  String get description => 'A flamboyant singer whose voice can both heal and harm. Beware the discordant notes!';
} 