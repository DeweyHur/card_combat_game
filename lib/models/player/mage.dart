import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';

class Mage extends PlayerBase {
  Mage() : super(
    name: 'Mage',
    maxHealth: 80,
    attack: 20,
    defense: 5,
    emoji: '🧙',
    color: Colors.purple,
    deck: [
      slash,
      poison,
      heal,
      greaterHeal,
      cleanse,
    ],
    description: 'Low HP, deals 50% more damage',
  );

  @override
  int get maxEnergy => 4;

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.5).round(); // Mage deals 50% more damage
  }
} 