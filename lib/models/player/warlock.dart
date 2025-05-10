import 'package:card_combat_app/models/game_card.dart';
import 'player_base.dart';
import 'package:flutter/material.dart';

class Warlock extends PlayerBase {
  Warlock() : super(
    name: 'Warlock',
    maxHealth: 90,
    deck: [],
  );

  @override
  void startTurn() {
    super.startTurn();
    // Warlock takes 2 damage at the start of their turn but gets +1 energy
    takeDamage(2);
    energy = maxEnergy + 1;
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