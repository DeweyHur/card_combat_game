import 'game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class GameCharacter {
  final String name;
  final int maxHealth;
  int currentHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  final String imagePath;
  final String soundPath;
  final String description;
  final List<GameCard> deck;

  final int maxEnergy;
  int currentEnergy;

  // Mutable combat state
  Map<StatusEffect, int> statusEffects = {};

  List<GameCard> hand = [];
  int handSize;
  List<GameCard> discardPile = [];

  int shield = 0;

  GameCharacter({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.soundPath,
    required this.description,
    required this.deck,
    this.maxEnergy = 3,
    this.handSize = 5,
  }) : currentHealth = maxHealth,
       currentEnergy = maxEnergy;

  void addStatusEffect(StatusEffect effect, int amount) {
    if (effect == StatusEffect.none) return;
    if (effect == StatusEffect.poison) {
      // Poison stacks: add to existing amount
      statusEffects[StatusEffect.poison] = (statusEffects[StatusEffect.poison] ?? 0) + amount;
      GameLogger.info(LogCategory.combat, '\x1B[32m$name\x1B[0m is poisoned for ${statusEffects[StatusEffect.poison]}');
    } else {
      // Other effects: overwrite duration
      statusEffects[effect] = amount;
      GameLogger.info(LogCategory.combat, '\x1B[32m$name\x1B[0m is affected by $effect for $amount turns');
    }
  }

  void removeStatusEffect(StatusEffect effect) {
    statusEffects.remove(effect);
    GameLogger.info(LogCategory.combat, '[32m$name[0m $effect removed');
  }

  void updateStatusEffects() {
    final expired = <StatusEffect>[];
    statusEffects.forEach((effect, value) {
      if (effect == StatusEffect.poison) {
        // Poison stack is reduced in onTurnStart, not here
        if (statusEffects[effect]! <= 0) expired.add(effect);
      } else {
        statusEffects[effect] = value - 1;
        if (statusEffects[effect]! <= 0) expired.add(effect);
      }
    });
    for (final effect in expired) {
      removeStatusEffect(effect);
    }
  }

  void onTurnStart() {
    // Apply all status effects
    final expired = <StatusEffect>[];
    statusEffects.forEach((effect, value) {
      switch (effect) {
        case StatusEffect.poison:
          if (value > 0) {
            // Poison damage bypasses shield
            currentHealth = (currentHealth - value).clamp(0, maxHealth);
            GameLogger.info(LogCategory.combat, '\x1B[32m$name\x1B[0m takes $value poison damage (bypasses shield). Health: $currentHealth/$maxHealth');
            // Reduce poison stack by 1
            statusEffects[StatusEffect.poison] = value - 1;
            if (statusEffects[StatusEffect.poison]! <= 0) expired.add(StatusEffect.poison);
          }
          break;
        case StatusEffect.burn:
          takeDamage(3);
          GameLogger.info(LogCategory.combat, '\x1B[32m$name\x1B[0m takes 3 burn damage');
          break;
        case StatusEffect.freeze:
          // Freeze effect is handled in the combat logic
          GameLogger.info(LogCategory.combat, '\x1B[32m$name\x1B[0m is frozen');
          break;
        case StatusEffect.none:
          break;
      }
    });
    for (final effect in expired) {
      removeStatusEffect(effect);
    }
    // Update other status effects (burn, freeze, etc.)
    updateStatusEffects();
  }

  void takeDamage(int damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
    GameLogger.info(LogCategory.combat, '[32m$name[0m takes $damage damage. Health: $currentHealth/$maxHealth');
  }
} 