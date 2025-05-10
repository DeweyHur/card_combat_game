import 'game_card.dart';

final List<GameCard> gameCards = [
  GameCard(
    name: 'Slash',
    description: 'Deal 5 damage',
    type: CardType.attack,
    value: 5,
  ),
  GameCard(
    name: 'Heal',
    description: 'Heal 5 HP',
    type: CardType.heal,
    value: 5,
  ),
  GameCard(
    name: 'Poison',
    description: 'Apply poison for 3 turns',
    type: CardType.statusEffect,
    value: 3,
    statusEffectToApply: StatusEffect.poison,
    statusDuration: 3,
  ),
  GameCard(
    name: 'Fireball',
    description: 'Deal 8 damage',
    type: CardType.attack,
    value: 8,
  ),
  GameCard(
    name: 'Cure',
    description: 'Remove all status effects',
    type: CardType.cure,
    value: 0,
  ),
  GameCard(
    name: 'Burn',
    description: 'Apply burn for 2 turns',
    type: CardType.statusEffect,
    value: 2,
    statusEffectToApply: StatusEffect.burn,
    statusDuration: 2,
  ),
  GameCard(
    name: 'Freeze',
    description: 'Apply freeze for 1 turn',
    type: CardType.statusEffect,
    value: 1,
    statusEffectToApply: StatusEffect.freeze,
    statusDuration: 1,
  ),
  GameCard(
    name: 'Greater Heal',
    description: 'Heal 8 HP',
    type: CardType.heal,
    value: 8,
  ),
  GameCard(
    name: 'Double Strike',
    description: 'Deal 6 damage twice',
    type: CardType.attack,
    value: 6,
  ),
  GameCard(
    name: 'Cleanse',
    description: 'Remove all status effects and heal 3 HP',
    type: CardType.cure,
    value: 3,
  ),
]; 