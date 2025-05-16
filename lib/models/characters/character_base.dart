import 'package:card_combat_app/models/game_card.dart';

abstract class CharacterBase {
  final String name;
  final String emoji;
  int currentHp;
  final int maxHp;
  final String color;
  Map<StatusEffect, int> statusEffects = {};

  CharacterBase({
    required this.name,
    required this.emoji,
    required this.maxHp,
    required this.color,
  }) : currentHp = maxHp;

  void takeDamage(int damage) {
    currentHp -= damage;
    if (currentHp < 0) currentHp = 0;
  }

  void heal(int amount) {
    currentHp += amount;
    if (currentHp > maxHp) currentHp = maxHp;
  }

  void addStatusEffect(StatusEffect effect, int amount) {
    if (effect == StatusEffect.poison) {
      statusEffects[StatusEffect.poison] = (statusEffects[StatusEffect.poison] ?? 0) + amount;
    } else {
      statusEffects[effect] = amount;
    }
  }

  void removeStatusEffect(StatusEffect effect) {
    statusEffects.remove(effect);
  }

  void clearStatusEffects() {
    statusEffects.clear();
  }

  bool hasStatusEffect(StatusEffect effect) {
    return statusEffects.containsKey(effect);
  }

  void updateStatusEffects() {
    final effectsToRemove = <StatusEffect>[];
    for (var entry in statusEffects.entries) {
      final effect = entry.key;
      final value = entry.value;
      if (effect == StatusEffect.poison) {
        if (value <= 0) effectsToRemove.add(effect);
      } else {
        statusEffects[effect] = value - 1;
        if (statusEffects[effect]! <= 0) effectsToRemove.add(effect);
      }
    }
    for (var effect in effectsToRemove) {
      statusEffects.remove(effect);
    }
  }

  void onTurnStart() {
    final effectsToRemove = <StatusEffect>[];
    for (var entry in statusEffects.entries) {
      final effect = entry.key;
      final value = entry.value;
      switch (effect) {
        case StatusEffect.poison:
          if (value > 0) {
            currentHp -= value;
            if (currentHp < 0) currentHp = 0;
            statusEffects[StatusEffect.poison] = value - 1;
            if (statusEffects[StatusEffect.poison]! <= 0) effectsToRemove.add(StatusEffect.poison);
          }
          break;
        default:
          break;
      }
    }
    for (var effect in effectsToRemove) {
      statusEffects.remove(effect);
    }
    updateStatusEffects();
  }

  String getStatusText() {
    if (statusEffects.isEmpty) {
      return '✨ No Status Effects';
    }
    
    final statusStrings = statusEffects.entries.map((entry) {
      final effect = entry.key;
      final duration = entry.value;
      String effectText = '${_getStatusEmoji(effect)} ${effect.toString().split('.').last}';
      return '$effectText ($duration)';
    }).join(', ');
    
    return '✨ Status: $statusStrings';
  }

  String _getStatusEmoji(StatusEffect effect) {
    switch (effect) {
      case StatusEffect.poison:
        return '☠️';
      case StatusEffect.burn:
        return '🔥';
      case StatusEffect.freeze:
        return '❄️';
      case StatusEffect.none:
        return '✨';
    }
  }

  bool get isAlive => currentHp > 0;
} 