import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';

class Knight extends PlayerBase {
  Knight() : super(
    name: 'Knight',
    maxHealth: 100,
    attack: 15,
    defense: 10,
    emoji: '🛡️',
    color: Colors.blue,
    deck: [
      slash,
      heavyStrike,
      heal,
      greaterHeal,
      cleanse,
    ],
    description: 'High HP, deals 20% more damage',
  );

  @override
  int get maxEnergy => 3;

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.2).round(); // Knight deals 20% more damage
  }
} 