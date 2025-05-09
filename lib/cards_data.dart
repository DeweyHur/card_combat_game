import 'package:card_combat_app/card.dart';

// This function initializes and returns a list of all available cards in the game.
List<Card> initializeCardPool() {
  return [
    // Attack Cards
    Card(id: 'atk001', name: 'Strike', description: 'Deal 5 damage', type: CardType.attack, value: 5),
    Card(id: 'atk002', name: 'Heavy Hit', description: 'Deal 8 damage', type: CardType.attack, value: 8),
    Card(id: 'atk003', name: 'Quick Jab', description: 'Deal 3 damage', type: CardType.attack, value: 3),

    // Heal Cards
    Card(id: 'heal001', name: 'Minor Mend', description: 'Heal 4 HP', type: CardType.heal, value: 4),
    Card(id: 'heal002', name: 'First Aid', description: 'Heal 7 HP', type: CardType.heal, value: 7),

    // Cure Card
    Card(id: 'cure001', name: 'Purify', description: 'Cure Poison & Burn', type: CardType.cure, value: 0), // Value might represent potency or be unused

    // Status Effect Cards
    Card(
      id: 'stat001',
      name: 'Poison Cloud',
      description: 'Poisons enemy.', // More detailed effect handled by game logic
      type: CardType.statusEffect,
      value: 0, // No immediate direct damage/value from playing the card itself
      statusEffectToApply: StatusEffect.poison,
      statusValue: 2, // 2 damage per turn
      statusDuration: 3, // for 3 turns
    ),
    Card(
      id: 'stat002',
      name: 'Immolate',
      description: 'Burns enemy.',
      type: CardType.statusEffect,
      value: 0,
      statusEffectToApply: StatusEffect.burn,
      statusValue: 3, // 3 damage per turn
      statusDuration: 2, // for 2 turns
    ),
    Card(
      id: 'stat003',
      name: 'Flash Freeze',
      description: 'Freezes enemy.',
      type: CardType.statusEffect,
      value: 0,
      statusEffectToApply: StatusEffect.freeze,
      statusValue: 0, // Freeze doesn't have a 'damage' value
      statusDuration: 1, // Freezes for 1 turn (enemy skips next action)
    ),
    // Add a few more for variety
    Card(id: 'atk004', name: 'Shield Bash', description: 'Deal 4 damage.', type: CardType.attack, value: 4),
    Card(id: 'heal003', name: 'Soothe Wounds', description: 'Heal 5 HP.', type: CardType.heal, value: 5),
  ];
}