import 'package:card_combat_app/models/game_card.dart';
import 'player_base.dart';
import 'package:flutter/material.dart';

class Sorcerer extends PlayerBase {
  Sorcerer() : super(
    name: 'Sorcerer',
    maxHealth: 80,
    deck: [],
  );

  @override
  void startTurn() {
    super.startTurn();
    // Sorcerer draws an additional card at the start of their turn
    drawCard();
  }

  @override
  void playCard(GameCard card) {
    if (card.type == CardType.statusEffect) {
      // Sorcerer's status effects last 1 turn longer
      card = GameCard(
        name: card.name,
        description: card.description,
        type: card.type,
        value: card.value,
        statusEffectToApply: card.statusEffectToApply,
        statusDuration: (card.statusDuration) + 1,
      );
    }
    super.playCard(card);
  }
} 