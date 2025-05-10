import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_card.dart';

abstract class CharacterBase {
  final String name;
  final String emoji;
  int currentHp;
  final int maxHp;
  final Color color;
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

  void addStatusEffect(StatusEffect effect, int duration) {
    statusEffects[effect] = duration;
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
      final duration = entry.value;
      
      if (duration <= 1) {
        effectsToRemove.add(effect);
      } else {
        statusEffects[effect] = duration - 1;
      }
    }
    
    for (var effect in effectsToRemove) {
      statusEffects.remove(effect);
    }
  }

  String getStatusText() {
    if (statusEffects.isEmpty) {
      return '✨ No Status Effects';
    }
    
    final statusStrings = statusEffects.entries.map((entry) {
      final effect = entry.key;
      final duration = entry.value;
      String effectText = _getStatusEmoji(effect) + ' ' + effect.toString().split('.').last;
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