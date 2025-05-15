import 'game_card.dart';

// Attack Cards
const GameCard slash = GameCard(
  name: 'Slash',
  description: 'Deal 5 damage',
  type: CardType.attack,
  value: 5,
  color: 'red',
);

const GameCard heavyStrike = GameCard(
  name: 'Heavy Strike',
  description: 'Deal 8 damage',
  type: CardType.attack,
  value: 8,
  color: 'red',
);

// Healing Cards
const GameCard heal = GameCard(
  name: 'Heal',
  description: 'Restore 3 HP',
  type: CardType.heal,
  value: 3,
  color: 'green',
);

const GameCard greaterHeal = GameCard(
  name: 'Greater Heal',
  description: 'Restore 5 HP',
  type: CardType.heal,
  value: 5,
  color: 'green',
);

// Status Effect Cards
const GameCard poison = GameCard(
  name: 'Poison',
  description: 'Apply poison for 3 turns',
  type: CardType.statusEffect,
  value: 2,
  statusEffectToApply: StatusEffect.poison,
  statusDuration: 3,
  color: 'purple',
);

// Cure Cards
const GameCard cleanse = GameCard(
  name: 'Cleanse',
  description: 'Remove all status effects',
  type: CardType.cure,
  value: 0,
  color: 'blue',
);

// Shield Cards
const GameCard shieldUp = GameCard(
  name: 'Shield Up',
  description: 'Gain 8 shield',
  type: CardType.shield,
  value: 8,
  color: 'blueGrey',
);

const GameCard shieldBash = GameCard(
  name: 'Shield Bash',
  description: 'Attack with your shield value (consumes shield)',
  type: CardType.shieldAttack,
  value: 0, // Value is determined at play time
  color: 'amber',
);

// List of all available cards
final List<GameCard> gameCards = [
  slash,
  heavyStrike,
  heal,
  greaterHeal,
  poison,
  cleanse,
  shieldUp,
  shieldBash,
]; 