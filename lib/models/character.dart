import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'game_card.dart';

class Character {
  final String name;
  int maxHealth;
  int currentHealth;
  final List<StatusEffect> activeStatusEffects = [];
  final Map<StatusEffect, int> statusDurations = {};

  Character({
    required this.name,
    required this.maxHealth,
  }) : currentHealth = maxHealth;

  void takeDamage(int amount) {
    currentHealth = (currentHealth - amount).clamp(0, maxHealth);
    GameLogger.info(LogCategory.game, '$name took $amount damage. Health: $currentHealth/$maxHealth');
  }

  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
    GameLogger.info(LogCategory.game, '$name healed for $amount. Health: $currentHealth/$maxHealth');
  }

  void addStatusEffect(StatusEffect effect, int duration) {
    if (!activeStatusEffects.contains(effect)) {
      activeStatusEffects.add(effect);
      statusDurations[effect] = duration;
      GameLogger.info(LogCategory.game, '$name received $effect for $duration turns');
    } else {
      statusDurations[effect] = duration;
      GameLogger.info(LogCategory.game, '$name\'s $effect duration refreshed to $duration turns');
    }
  }

  void removeStatusEffect(StatusEffect effect) {
    activeStatusEffects.remove(effect);
    statusDurations.remove(effect);
    GameLogger.info(LogCategory.game, '$effect removed from $name');
  }

  void removeAllStatusEffects() {
    activeStatusEffects.clear();
    statusDurations.clear();
    GameLogger.info(LogCategory.game, 'All status effects removed from $name');
  }

  bool hasStatusEffect(StatusEffect effect) {
    return activeStatusEffects.contains(effect);
  }

  void updateStatusEffects() {
    final effectsToRemove = <StatusEffect>[];
    for (final effect in activeStatusEffects) {
      statusDurations[effect] = (statusDurations[effect] ?? 0) - 1;
      if (statusDurations[effect]! <= 0) {
        effectsToRemove.add(effect);
      }
    }
    for (final effect in effectsToRemove) {
      removeStatusEffect(effect);
    }
  }

  GameCard getNextAction() {
    // This is a placeholder. Enemy classes will override this method
    return GameCard(
      name: 'Basic Attack',
      description: 'A basic attack',
      type: CardType.attack,
      value: 5,
    );
  }
} 