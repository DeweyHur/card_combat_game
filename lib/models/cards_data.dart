import 'card.dart';

List<Card> initializeCardPool() {
  return [
    const Card(
      name: 'Slash',
      type: CardType.attack,
      value: 5,
      description: 'Deal 5 damage',
    ),
    const Card(
      name: 'Heavy Strike',
      type: CardType.attack,
      value: 8,
      description: 'Deal 8 damage',
    ),
    const Card(
      name: 'Quick Strike',
      type: CardType.attack,
      value: 3,
      description: 'Deal 3 damage',
    ),
    const Card(
      name: 'Heal',
      type: CardType.heal,
      value: 5,
      description: 'Restore 5 HP',
    ),
    const Card(
      name: 'Greater Heal',
      type: CardType.heal,
      value: 8,
      description: 'Restore 8 HP',
    ),
    const Card(
      name: 'Minor Heal',
      type: CardType.heal,
      value: 3,
      description: 'Restore 3 HP',
    ),
    const Card(
      name: 'Poison',
      type: CardType.statusEffect,
      value: 2,
      description: 'Apply poison (2 damage per turn)',
      statusEffectToApply: 'poison',
    ),
    const Card(
      name: 'Weaken',
      type: CardType.statusEffect,
      value: 2,
      description: 'Reduce enemy damage by 2',
      statusEffectToApply: 'weak',
    ),
    const Card(
      name: 'Cure',
      type: CardType.cure,
      value: 5,
      description: 'Remove all status effects and heal 5 HP',
    ),
  ];
} 