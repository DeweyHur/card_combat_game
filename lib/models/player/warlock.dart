import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';

class Warlock extends PlayerBase {
  Warlock() : super(
    name: 'Warlock',
    maxHealth: 90,
    attack: 20,
    defense: 5,
    emoji: '👹',
    color: Colors.red,
    deck: [
      slash,
      poison,
      heal,
      greaterHeal,
      cleanse,
    ],
    description: 'Medium HP, takes 2 damage per turn but gets +1 energy, attack cards deal +2 damage but cost +1 energy',
  );

  @override
  int get maxEnergy => 4;

  @override
  void onTurnStart() {
    super.onTurnStart();
    takeDamage(2); // Take 2 damage at the start of each turn
    energy += 1; // Get +1 energy
  }

  @override
  int calculateDamage(int baseDamage) {
    return baseDamage + 2; // Attack cards deal +2 damage
  }

  @override
  int calculateEnergyCost(int baseCost) {
    return baseCost + 1; // Attack cards cost +1 energy
  }

  @override
  void playCard(GameCard card) {
    if (card.type == CardType.attack) {
      // Warlock's attack cards deal 2 additional damage but cost 1 more energy
      card = GameCard(
        name: card.name,
        description: card.description,
        type: card.type,
        value: card.value + 2,
        statusEffectToApply: card.statusEffectToApply,
        statusDuration: card.statusDuration,
      );
      energy--; // Additional energy cost
    }
    super.playCard(card);
  }
} 