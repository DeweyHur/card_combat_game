enum CardType {
  attack, // Deals direct damage
  heal,   // Restores player HP
  cure,   // Removes negative status effects from the player
  statusEffect, // Applies a status effect (e.g., poison, burn, freeze) to the enemy
}

enum StatusEffect {
  none,   // No status effect
  poison, // Damage over time
  burn,   // Damage over time (can be different from poison)
  freeze, // Prevents enemy action
}

class Card {
  final String id; // Unique identifier for the card type
  final String name;
  final String description; // Short text explaining what the card does
  final CardType type;
  final int value; // Base value: damage for attack, heal amount for heal
  
  // Fields specific to status effects
  final StatusEffect statusEffectToApply;
  final int? statusValue; // e.g., damage per turn for DoT, or potency
  final int? statusDuration; // How many turns the status lasts

  Card({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value, // Non-status cards will use this primarily
    this.statusEffectToApply = StatusEffect.none,
    this.statusValue,
    this.statusDuration,
  });

  @override
  String toString() => 'Card($name, $type, value: $value)';
}