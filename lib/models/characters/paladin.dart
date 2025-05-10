import 'package:flutter/material.dart';
import '../../models/game_card.dart';
import 'player_base.dart';

class Paladin extends PlayerBase {
  Paladin() : super(
    name: 'Paladin',
    maxHealth: 120,
    deck: [],
  );

  @override
  void startTurn() {
    super.startTurn();
    // Paladin heals 2 HP at the start of their turn
    heal(2);
  }

  @override
  void playCard(GameCard card) {
    if (card.type == CardType.heal) {
      // Paladin's healing cards heal 2 additional HP
      card = GameCard(
        name: card.name,
        description: card.description,
        type: card.type,
        value: card.value + 2,
        statusEffectToApply: card.statusEffectToApply,
        statusDuration: card.statusDuration,
      );
    }
    super.playCard(card);
  }
} 