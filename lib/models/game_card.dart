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
  final int statusDuration;

  const GameCard({
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.statusEffectToApply,
    this.statusDuration = 0,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$name: ');
    
    switch (type) {
      case CardType.attack:
        buffer.write('Deal $value damage');
        break;
      case CardType.heal:
        buffer.write('Heal $value HP');
        break;
      case CardType.statusEffect:
        if (statusEffectToApply != null) {
          buffer.write('Apply ${statusEffectToApply.toString().split('.').last} for $statusDuration turns');
          if (value > 0) {
            buffer.write(' and deal $value damage');
          }
        }
        break;
      case CardType.cure:
        buffer.write('Remove all status effects');
        break;
    }
    
    return buffer.toString();
  }
} 