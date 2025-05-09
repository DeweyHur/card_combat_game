enum CardType {
  attack,
  heal,
  statusEffect,
  cure,
}

class Card {
  final String name;
  final CardType type;
  final int value;
  final String description;
  final String? statusEffectToApply;

  const Card({
    required this.name,
    required this.type,
    required this.value,
    required this.description,
    this.statusEffectToApply,
  });
} 