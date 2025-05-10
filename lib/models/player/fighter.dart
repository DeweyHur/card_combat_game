import 'package:card_combat_app/models/game_card.dart';
import 'player_base.dart';
import 'package:flutter/material.dart';

class Fighter extends PlayerBase {
  Fighter() : super(
    name: 'Fighter',
    maxHealth: 100,
    deck: [],
  );

  @override
  void startTurn() {
    super.startTurn();
    // Fighter gets +1 energy at the start of their turn
    energy = maxEnergy + 1;
  }

  @override
  void playCard(GameCard card) {
    if (card.type == CardType.attack) {
      // Fighter's attack cards deal 1 additional damage
      card = GameCard(
        name: card.name,
        description: card.description,
        type: card.type,
        value: card.value + 1,
        statusEffectToApply: card.statusEffectToApply,
        statusDuration: card.statusDuration,
      );
    }
    super.playCard(card);
  }
} 