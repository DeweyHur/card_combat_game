import 'game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameCharacter {
  final String name;
  final int maxHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  final String imagePath;
  final String soundPath;
  final String description;
  List<GameCard> deck = [];
  final int maxEnergy;
  int handSize;

  // --- Property Watchers ---
  final Map<String, List<Function(dynamic)>> _propertyWatchers = {};

  // --- Property Getters/Setters with Notification ---
  int _currentHealth;
  int get currentHealth => _currentHealth;
  set currentHealth(int value) {
    if (_currentHealth != value) {
      _currentHealth = value;
      _notify('currentHealth', value);
    }
  }

  int _currentEnergy;
  int get currentEnergy => _currentEnergy;
  set currentEnergy(int value) {
    if (_currentEnergy != value) {
      _currentEnergy = value;
      _notify('currentEnergy', value);
    }
  }

  int _shield = 0;
  int get shield => _shield;
  set shield(int value) {
    if (_shield != value) {
      _shield = value;
      _notify('shield', value);
    }
  }

  // --- Equipment (reactive) ---
  Map<String, String> _equipment = {};
  Map<String, String> get equipment => Map.unmodifiable(_equipment);
  set equipment(Map<String, String> value) {
    _equipment = Map.from(value);
    _notify('equipment', equipment);
  }

  /// Equip an item to a slot (notifies both 'equipment' and 'equipment:<slot>')
  void equip(String slot, String itemName) {
    _equipment[slot] = itemName;
    _notify('equipment', equipment);
    _notify('equipment:$slot', itemName);
  }

  /// Unequip an item from a slot (notifies both 'equipment' and 'equipment:<slot>')
  void unequip(String slot) {
    if (_equipment.containsKey(slot)) {
      _equipment.remove(slot);
      _notify('equipment', equipment);
      _notify('equipment:$slot', null);
    }
  }

  // Mutable combat state
  Map<StatusEffect, int> statusEffects = {};
  List<GameCard> hand = [];
  List<GameCard> discardPile = [];

  GameCharacter({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    this.imagePath = '',
    this.soundPath = '',
    required this.description,
    List<GameCard>? deck,
    Map<String, String>? equipment,
    this.maxEnergy = 3,
    this.handSize = 5,
  })  : _currentHealth = maxHealth,
        _currentEnergy = maxEnergy {
    if (deck != null) this.deck = deck;
    if (equipment != null) this.equipment = equipment;
  }

  void setDeck(List<GameCard> newDeck) {
    deck = newDeck;
  }

  // --- Watch/Unwatch/Notify ---
  void watch(String property, Function(dynamic) callback) {
    _propertyWatchers.putIfAbsent(property, () => []).add(callback);
  }

  void unwatch(String property, Function(dynamic) callback) {
    _propertyWatchers[property]?.remove(callback);
  }

  void _notify(String property, dynamic value) {
    if (_propertyWatchers.containsKey(property)) {
      for (final cb in _propertyWatchers[property]!) {
        cb(value);
      }
    }
  }

  void addStatusEffect(StatusEffect effect, int amount) {
    if (effect == StatusEffect.none) return;
    if (effect == StatusEffect.poison) {
      // Poison stacks: add to existing amount
      statusEffects[StatusEffect.poison] =
          (statusEffects[StatusEffect.poison] ?? 0) + amount;
      GameLogger.info(LogCategory.combat,
          '\x1B[32m$name\x1B[0m is poisoned for [32m${statusEffects[StatusEffect.poison]}\x1B[0m');
    } else if (effect == StatusEffect.burn) {
      // Burn stacks: add to existing amount
      statusEffects[StatusEffect.burn] =
          (statusEffects[StatusEffect.burn] ?? 0) + amount;
      GameLogger.info(LogCategory.combat,
          '\x1B[32m$name\x1B[0m is burned for [31m${statusEffects[StatusEffect.burn]}\x1B[0m');
    } else {
      // Other effects: overwrite duration
      statusEffects[effect] = amount;
      GameLogger.info(LogCategory.combat,
          '\x1B[32m$name\x1B[0m is affected by $effect for $amount turns');
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
            GameLogger.info(LogCategory.combat,
                '\x1B[32m$name\x1B[0m takes $value poison damage (bypasses shield). Health: $currentHealth/$maxHealth');
            // Reduce poison stack by 1
            statusEffects[StatusEffect.poison] = value - 1;
            if (statusEffects[StatusEffect.poison]! <= 0) {
              expired.add(StatusEffect.poison);
            }
          }
          break;
        case StatusEffect.burn:
          if (value > 0) {
            // Burn damage: apply to shield first, then HP
            int burnDamage = value;
            if (shield > 0) {
              if (shield >= burnDamage) {
                shield -= burnDamage;
                GameLogger.info(LogCategory.combat,
                    '$name loses $burnDamage shield from burn. Shield: $shield');
              } else {
                int remaining = burnDamage - shield;
                GameLogger.info(LogCategory.combat,
                    '$name loses $shield shield from burn. Shield: 0');
                shield = 0;
                currentHealth = (currentHealth - remaining).clamp(0, maxHealth);
                GameLogger.info(LogCategory.combat,
                    '$name takes $remaining burn damage. Health: $currentHealth/$maxHealth');
              }
            } else {
              currentHealth = (currentHealth - burnDamage).clamp(0, maxHealth);
              GameLogger.info(LogCategory.combat,
                  '$name takes $burnDamage burn damage. Health: $currentHealth/$maxHealth');
            }
            // Halve the burn stack (rounded down)
            int newBurn = (value / 2).floor();
            if (newBurn > 0) {
              statusEffects[StatusEffect.burn] = newBurn;
              GameLogger.info(
                  LogCategory.combat, '$name burn stack is now $newBurn');
            } else {
              expired.add(StatusEffect.burn);
            }
          }
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
    GameLogger.info(LogCategory.combat,
        '[32m$name[0m takes $damage damage. Health: $currentHealth/$maxHealth');
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'maxHealth': maxHealth,
        'attack': attack,
        'defense': defense,
        'emoji': emoji,
        'color': color,
        'imagePath': imagePath,
        'soundPath': soundPath,
        'description': description,
        'deck': deck.map((c) => c.toJson()).toList(),
        'maxEnergy': maxEnergy,
        'handSize': handSize,
        'equipment': _equipment,
      };

  static GameCharacter fromJson(Map<String, dynamic> json) {
    final character = GameCharacter(
      name: json['name'],
      maxHealth: json['maxHealth'],
      attack: json['attack'],
      defense: json['defense'],
      emoji: json['emoji'],
      color: json['color'],
      imagePath: json['imagePath'],
      soundPath: json['soundPath'],
      description: json['description'],
      deck: (json['deck'] as List).map((c) => GameCard.fromJson(c)).toList(),
      maxEnergy: json['maxEnergy'] ?? 3,
      handSize: json['handSize'] ?? 5,
    );

    // Load saved equipment synchronously
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      final savedEquipment =
          prefs.getString('playerEquipment:${character.name}');
      if (savedEquipment != null) {
        try {
          final equipmentMap =
              Map<String, String>.from(jsonDecode(savedEquipment));
          character.equipment = equipmentMap;
          // Force UI update after loading equipment
          character._notify('equipment', character.equipment);
        } catch (e) {
          GameLogger.error(
              LogCategory.data, 'Error loading saved equipment: $e');
        }
      } else {
        // If no saved equipment, load defaults from JSON
        if (json['equipment'] != null) {
          character.equipment = Map<String, String>.from(json['equipment']);
          // Force UI update after loading default equipment
          character._notify('equipment', character.equipment);
        }
      }
    });

    return character;
  }
}
