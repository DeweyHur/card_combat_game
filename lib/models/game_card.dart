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
  final int cost;
  final StatusEffect? statusEffectToApply;
  final int? statusDuration;
  final String color;
  final String target; // 'player' or 'enemy' (or 'self')

  const GameCard({
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.cost,
    this.statusEffectToApply,
    this.statusDuration,
    this.color = "blue",
    this.target = "enemy", // default for player cards
  });

  @override
  String toString() => name;
}

extension GameCardClone on GameCard {
  GameCard copyWith({
    int? value,
    int? cost,
    StatusEffect? statusEffectToApply,
    int? statusDuration,
    String? color,
    String? target,
  }) {
    return GameCard(
      name: name,
      description: description,
      type: type,
      value: value ?? this.value,
      cost: cost ?? this.cost,
      statusEffectToApply: statusEffectToApply ?? this.statusEffectToApply,
      statusDuration: statusDuration ?? this.statusDuration,
      color: color ?? this.color,
      target: target ?? this.target,
    );
  }
} 