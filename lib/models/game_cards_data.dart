import 'package:flutter/material.dart';
import 'game_card.dart';

// Attack Cards
final GameCard slash = GameCard(
  name: 'Slash',
  description: 'Deal 5 damage',
  type: CardType.attack,
  value: 5,
  color: Colors.red,
);

final GameCard heavyStrike = GameCard(
  name: 'Heavy Strike',
  description: 'Deal 8 damage',
  type: CardType.attack,
  value: 8,
  color: Colors.red,
);

// Healing Cards
final GameCard heal = GameCard(
  name: 'Heal',
  description: 'Restore 3 HP',
  type: CardType.heal,
  value: 3,
  color: Colors.green,
);

final GameCard greaterHeal = GameCard(
  name: 'Greater Heal',
  description: 'Restore 5 HP',
  type: CardType.heal,
  value: 5,
  color: Colors.green,
);

// Status Effect Cards
final GameCard poison = GameCard(
  name: 'Poison',
  description: 'Apply poison for 3 turns',
  type: CardType.statusEffect,
  value: 2,
  statusEffectToApply: StatusEffect.poison,
  statusDuration: 3,
  color: Colors.purple,
);

// Cure Cards
final GameCard cleanse = GameCard(
  name: 'Cleanse',
  description: 'Remove all status effects',
  type: CardType.cure,
  value: 0,
  color: Colors.blue,
);

// List of all available cards
final List<GameCard> gameCards = [
  slash,
  heavyStrike,
  heal,
  greaterHeal,
  poison,
  cleanse,
]; 