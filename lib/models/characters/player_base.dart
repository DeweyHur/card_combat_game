import 'package:flutter/material.dart';
import '../../models/game_card.dart';
import 'character_base.dart';
import 'package:flame/components.dart';
import '../character.dart';

abstract class PlayerBase extends Character {
  List<GameCard> deck;
  List<GameCard> hand = [];
  List<GameCard> discardPile = [];
  int energy = 3;
  int maxEnergy = 3;

  PlayerBase({
    required String name,
    required int maxHealth,
    required this.deck,
  }) : super(name: name, maxHealth: maxHealth);

  void drawCard() {
    if (deck.isEmpty) {
      if (discardPile.isEmpty) return;
      deck = List.from(discardPile);
      discardPile.clear();
      deck.shuffle();
    }
    hand.add(deck.removeLast());
  }

  void drawInitialHand() {
    for (int i = 0; i < 5; i++) {
      drawCard();
    }
  }

  void playCard(GameCard card) {
    if (!hand.contains(card)) return;
    hand.remove(card);
    discardPile.add(card);
  }

  void endTurn() {
    energy = maxEnergy;
  }

  void startTurn() {
    energy = maxEnergy;
    drawCard();
  }

  void shuffleDeck() {
    deck.shuffle();
  }
} 