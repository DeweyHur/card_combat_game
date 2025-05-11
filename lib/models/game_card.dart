import 'package:flutter/material.dart' hide Card;

enum CardType {
  attack,
  heal,
  statusEffect,
  cure,
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
  final Color color;

  const GameCard({
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.statusEffectToApply,
    this.statusDuration,
    this.color = Colors.blue,
  });

  @override
  String toString() => name;
} 