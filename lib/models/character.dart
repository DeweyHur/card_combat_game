import 'package:card_combat_app/utils/game_logger.dart';
import 'game_card.dart';

abstract class Character {
  final String name;
  final int maxHealth;
  int currentHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  StatusEffect? statusEffect;
  int? statusDuration;
  /// Shield can grow without limit and absorbs damage before HP.
  int shield = 0;

  Character({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
  }) : currentHealth = maxHealth;

  /// Damage is applied to shield first, then HP. If [bypassShield] is true, damage goes directly to HP (for Poison/Penetrate).
  void takeDamage(int damage, {bool bypassShield = false}) {
    if (!bypassShield && shield > 0) {
      if (shield >= damage) {
        shield -= damage;
        GameLogger.info(LogCategory.combat, '$name loses $damage shield. Shield: $shield');
        return;
      } else {
        int remaining = damage - shield;
        GameLogger.info(LogCategory.combat, '$name loses $shield shield. Shield: 0');
        shield = 0;
        currentHealth = (currentHealth - remaining).clamp(0, maxHealth);
        GameLogger.info(LogCategory.combat, '$name takes $remaining damage. Health: $currentHealth/$maxHealth');
        return;
      }
    }
    // If bypassShield or no shield
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
    GameLogger.info(LogCategory.combat, '$name takes $damage damage. Health: $currentHealth/$maxHealth');
  }

  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
    GameLogger.info(LogCategory.combat, '$name heals for $amount. Health: $currentHealth/$maxHealth');
  }

  void addStatusEffect(StatusEffect effect, int duration) {
    statusEffect = effect;
    statusDuration = duration;
    GameLogger.info(LogCategory.combat, '$name is affected by $effect for $duration turns');
  }

  void removeStatusEffect() {
    statusEffect = null;
    statusDuration = null;
    GameLogger.info(LogCategory.combat, '$name status effects removed');
  }

  void updateStatusEffects() {
    if (statusEffect != null && statusDuration != null) {
      statusDuration = statusDuration! - 1;
      if (statusDuration! <= 0) {
        removeStatusEffect();
      }
    }
  }

  void onTurnStart() {
    updateStatusEffects();
    // Apply status effect damage if applicable
    if (statusEffect != null) {
      switch (statusEffect!) {
        case StatusEffect.poison:
          takeDamage(2);
          GameLogger.info(LogCategory.combat, '$name takes 2 poison damage');
          break;
        case StatusEffect.burn:
          takeDamage(3);
          GameLogger.info(LogCategory.combat, '$name takes 3 burn damage');
          break;
        case StatusEffect.freeze:
          // Freeze effect is handled in the combat logic
          GameLogger.info(LogCategory.combat, '$name is frozen');
          break;
        case StatusEffect.none:
          break;
      }
    }
  }

  bool isAlive() => currentHealth > 0;

  /// Increase shield by [amount].
  void addShield(int amount) {
    shield += amount;
    GameLogger.info(LogCategory.combat, '$name gains $amount shield. Shield: $shield');
  }
} 