import 'package:flutter/foundation.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'name_emoji_interface.dart';

enum StatusEffect {
  none,
  poison,
  burn,
  freeze,
  stun,
  vulnerable,
  weak,
  strength,
  dexterity,
  regeneration,
  shield,
}

abstract class GameCharacter extends ChangeNotifier
    implements NameEmojiInterface {
  // Core stats
  final int maxHealth;
  int _currentHealth;
  int get currentHealth => _currentHealth;
  set currentHealth(int value) {
    if (_currentHealth != value) {
      _currentHealth = value.clamp(0, maxHealth);
      notifyListeners();
    }
  }

  // Shield
  int _currentShield = 0;
  int get currentShield => _currentShield;
  set currentShield(int value) {
    if (_currentShield != value) {
      _currentShield = value.clamp(0, 999);
      notifyListeners();
    }
  }

  // Combat state
  Map<StatusEffect, int> statusEffects = {};

  // Name and emoji
  String get name;
  String get emoji;

  GameCharacter({
    required this.maxHealth,
  }) : _currentHealth = maxHealth;

  // Combat actions
  void takeDamage(int amount) {
    if (_currentShield > 0) {
      if (_currentShield >= amount) {
        _currentShield -= amount;
        amount = 0;
      } else {
        amount -= _currentShield;
        _currentShield = 0;
      }
    }
    if (amount > 0) {
      currentHealth = currentHealth - amount;
      GameLogger.info(LogCategory.combat,
          'Takes $amount damage. Health: $currentHealth/$maxHealth');
    }
  }

  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
    GameLogger.info(LogCategory.combat,
        'Heals for $amount. Health: $currentHealth/$maxHealth');
  }

  void addShield(int amount) {
    currentShield = _currentShield + amount;
    GameLogger.info(
        LogCategory.combat, 'Gains $amount shield. Shield: $_currentShield');
  }

  bool isDead() => currentHealth <= 0;

  // Status effects
  void addStatusEffect(StatusEffect effect, int amount) {
    if (effect == StatusEffect.none) return;
    if (effect == StatusEffect.poison) {
      statusEffects[StatusEffect.poison] =
          (statusEffects[StatusEffect.poison] ?? 0) + amount;
      GameLogger.info(LogCategory.combat,
          'Is poisoned for ${statusEffects[StatusEffect.poison]}');
    } else if (effect == StatusEffect.burn) {
      statusEffects[StatusEffect.burn] =
          (statusEffects[StatusEffect.burn] ?? 0) + amount;
      GameLogger.info(LogCategory.combat,
          'Is burned for ${statusEffects[StatusEffect.burn]}');
    } else {
      statusEffects[effect] = amount;
      GameLogger.info(
          LogCategory.combat, 'Is affected by $effect for $amount turns');
    }
    notifyListeners();
  }

  void removeStatusEffect(StatusEffect effect) {
    statusEffects.remove(effect);
    GameLogger.info(LogCategory.combat, '$effect removed');
    notifyListeners();
  }

  void updateStatusEffects() {
    final expired = <StatusEffect>[];
    statusEffects.forEach((effect, value) {
      if (effect == StatusEffect.poison) {
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
    statusEffects.forEach((effect, value) {
      switch (effect) {
        case StatusEffect.poison:
          if (value > 0) {
            currentHealth = (currentHealth - value).clamp(0, maxHealth);
            GameLogger.info(LogCategory.combat,
                'Takes $value poison damage. Health: $currentHealth/$maxHealth');
            statusEffects[StatusEffect.poison] = value - 1;
            if (statusEffects[StatusEffect.poison]! <= 0) {
              removeStatusEffect(StatusEffect.poison);
            }
          }
          break;
        case StatusEffect.burn:
          if (value > 0) {
            currentHealth = (currentHealth - value).clamp(0, maxHealth);
            GameLogger.info(LogCategory.combat,
                'Takes $value burn damage. Health: $currentHealth/$maxHealth');
            statusEffects[StatusEffect.burn] = value - 1;
            if (statusEffects[StatusEffect.burn]! <= 0) {
              removeStatusEffect(StatusEffect.burn);
            }
          }
          break;
        default:
          break;
      }
    });
  }

  void clearStatusEffects() {
    statusEffects.clear();
    notifyListeners();
  }
}
