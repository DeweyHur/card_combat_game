import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';

class Orc extends EnemyBase {
  Orc() : super(
    name: 'Orc',
    maxHealth: 100,
    attack: 15,
    defense: 10,
    emoji: '👹',
    color: Colors.red,
  );

  @override
  GameCard selectAction() {
    // Simple AI: 80% chance to use heavy strike, 20% chance to heal
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 80) {
      return heavyStrike;
    } else {
      return GameCard(
        name: 'Orc Healing',
        description: 'Heals the orc',
        type: CardType.heal,
        value: 10,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.3).round(); // Orc deals 30% more damage
  }
} 