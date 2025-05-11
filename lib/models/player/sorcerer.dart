import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:flutter/material.dart';

class Sorcerer extends PlayerBase {
  Sorcerer() : super(
    name: 'Sorcerer',
    maxHealth: 80,
    attack: 15,
    defense: 5,
    emoji: '🧙‍♂️',
    color: Colors.blue,
    deck: [
      slash,
      poison,
      heal,
      greaterHeal,
      cleanse,
    ],
    description: 'Low HP, draws extra card, status effects last longer',
  );

  @override
  int get maxEnergy => 3;

  @override
  int get cardsToDraw => 2; // Draw an extra card each turn

  @override
  int get statusEffectDuration => 3; // Status effects last longer

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
        statusDuration: (card.statusDuration ?? 0) + 1,
      );
    }
    super.playCard(card);
  }
} 