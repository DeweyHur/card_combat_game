import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart' as cards;
import 'package:flutter/material.dart';

class Paladin extends PlayerBase {
  static final List<GameCard> _defaultDeck = [
    cards.slash,
    cards.poison,
    cards.heal,
    cards.greaterHeal,
    cards.cleanse,
  ];

  Paladin() : super(
    name: 'Paladin',
    maxHealth: 120,
    attack: 15,
    defense: 10,
    emoji: '🛡️',
    color: Colors.amber,
    deck: _defaultDeck,
    description: 'Highest HP, heals 2 HP per turn, all healing effects are increased by 2',
  );

  @override
  int get maxEnergy => 3;

  @override
  void onTurnStart() {
    super.onTurnStart();
    super.heal(2); // Heal 2 HP at the start of each turn
  }

  @override
  int calculateHealing(int baseHealing) {
    return baseHealing + 2; // Healing cards heal +2 HP
  }

  @override
  void heal(int amount) {
    super.heal(calculateHealing(amount));
  }

} 