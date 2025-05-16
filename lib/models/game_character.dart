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

  void addStatusEffect(StatusEffect effect, int duration) {
    if (effect == StatusEffect.none) return;
    statusEffects[effect] = duration;
    GameLogger.info(LogCategory.combat, '[32m$name[0m is affected by $effect for $duration turns');
  }

  void removeStatusEffect(StatusEffect effect) {
    statusEffects.remove(effect);
    GameLogger.info(LogCategory.combat, '[32m$name[0m $effect removed');
  }

  void updateStatusEffects() {
    final expired = <StatusEffect>[];
    statusEffects.forEach((effect, duration) {
      statusEffects[effect] = duration - 1;
      if (statusEffects[effect]! <= 0) expired.add(effect);
    });
    for (final effect in expired) {
      removeStatusEffect(effect);
    }
  }

  void onTurnStart() {
    updateStatusEffects();
    // Apply all status effects
    statusEffects.forEach((effect, duration) {
      switch (effect) {
        case StatusEffect.poison:
          takeDamage(2);
          GameLogger.info(LogCategory.combat, '[32m$name[0m takes 2 poison damage');
          break;
        case StatusEffect.burn:
          takeDamage(3);
          GameLogger.info(LogCategory.combat, '[32m$name[0m takes 3 burn damage');
          break;
        case StatusEffect.freeze:
          // Freeze effect is handled in the combat logic
          GameLogger.info(LogCategory.combat, '[32m$name[0m is frozen');
          break;
        case StatusEffect.none:
          break;
      }
    });
  }

  void takeDamage(int damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
    GameLogger.info(LogCategory.combat, '[32m$name[0m takes $damage damage. Health: $currentHealth/$maxHealth');
  }
} 