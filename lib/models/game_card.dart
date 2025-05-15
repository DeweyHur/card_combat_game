enum CardType {
  attack,
  heal,
  statusEffect,
  cure,
  shield,        // Adds shield to the player
  shieldAttack,  // Attacks using shield value
}

enum StatusEffect {
  none,
  poison,
  burn,
  freeze,
}

class GameCard {
  final String name;
  final String description;
  final CardType type;
  final int value;
  final StatusEffect? statusEffectToApply;
  final int? statusDuration;
  final String color;

  const GameCard({
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.statusEffectToApply,
    this.statusDuration,
    this.color = "blue",
  });

  @override
  String toString() => name;
} 