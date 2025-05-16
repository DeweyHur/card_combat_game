import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'dart:math';
import 'package:card_combat_app/components/layout/combat_scene_layout.dart';
import 'package:card_combat_app/components/panel/player_combat_panel.dart';

// --- Combat Event System ---
enum CombatEventType { damage, heal, status, cure }

class CombatEvent {
  final CombatEventType type;
  final GameCharacter target;
  final int value;
  final String description;
  final GameCard card;

  CombatEvent({
    required this.type,
    required this.target,
    required this.value,
    required this.description,
    required this.card,
  });
}

abstract class CombatWatcher {
  void onCombatEvent(CombatEvent event);
}
// --- End Combat Event System ---

class CombatManager {
  static final CombatManager _instance = CombatManager._internal();
  factory CombatManager() => _instance;
  CombatManager._internal();

  late GameCharacter player;
  late GameCharacter enemy;
  bool isPlayerTurn = true;
  final List<CombatWatcher> _watchers = [];
  final SoundManager _soundManager = SoundManager();

  // Store enemy actions by name for probability-based selection
  Map<String, List<dynamic>>? _enemyActionsByName; // dynamic for EnemyAction
  void setEnemyActionsByName(Map<String, List<dynamic>> actions) {
    _enemyActionsByName = actions;
  }

  // Store the last picked enemy action for UI
  GameCard? lastEnemyAction;

  void initialize({required GameCharacter player, required GameCharacter enemy}) {
    this.player = player;
    this.enemy = enemy;
    isPlayerTurn = true;
    _watchers.clear();
    _discardHand(player);
    _drawHand(player);
  }

  void startCombat() {
    GameLogger.info(LogCategory.game, 'Starting combat: ${player.name} vs ${enemy.name}');
    _initializePlayerDeck();
    _discardHand(player);
    _drawHand(player);
    // Draw initial hand logic can be implemented here if needed
  }

  void _initializePlayerDeck() {
    // Shuffle the player's deck at the start of combat
    player.deck.shuffle();
  }

  void _drawHand(GameCharacter character) {
    while (character.hand.length < character.handSize) {
      if (character.deck.isEmpty && character.discardPile.isNotEmpty) {
        // Move discard pile to deck and shuffle
        character.deck.addAll(character.discardPile);
        character.discardPile.clear();
        character.deck.shuffle();
      }
      if (character.deck.isEmpty) {
        break;
      }
      character.hand.add(character.deck.removeAt(0));
    }
  }

  void _discardHand(GameCharacter character) {
    character.discardPile.addAll(character.hand);
    character.hand.clear();
  }

  void addWatcher(CombatWatcher watcher) {
    _watchers.add(watcher);
  }

  void removeWatcher(CombatWatcher watcher) {
    _watchers.remove(watcher);
  }

  void _notifyWatchers(CombatEvent event) {
    for (final watcher in _watchers) {
      watcher.onCombatEvent(event);
    }
  }

  void playCard(GameCard card) {
    if (!isPlayerTurn) {
      GameLogger.warning(LogCategory.game, 'Not player\'s turn');
      return;
    }
    if (player.currentEnergy < card.cost) {
      GameLogger.warning(LogCategory.game, 'Not enough energy to play this card');
      return;
    }
    player.currentEnergy -= card.cost;
    GameLogger.info(LogCategory.game, 'Playing card: \'${card.name}\' (cost: ${card.cost}, remaining energy: ${player.currentEnergy})');
    _soundManager.playCardSound(card.type);

    // Always move the card from hand to discard pile if present
    if (player.hand.contains(card)) {
      player.hand.remove(card);
      player.discardPile.add(card);
    }

    switch (card.type) {
      case CardType.attack:
        enemyTakeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.damage,
          target: enemy,
          value: card.value,
          description: '\u001b[32m${player.name}\u001b[0m dealt ${card.value} damage',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Dealt \u001b[31m${card.value}\u001b[0m damage to \u001b[31m${enemy.name}\u001b[0m');
        break;
      case CardType.heal:
        playerHeal(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal,
          target: player,
          value: card.value,
          description: '\u001b[32m${player.name}\u001b[0m healed for ${card.value}',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Healed \u001b[32m${player.name}\u001b[0m for ${card.value} HP');
        break;
      case CardType.statusEffect:
        if (card.target == "enemy") {
          applyStatusEffectToEnemy(card);
        } else if (card.target == "player" || card.target == "self") {
          applyStatusEffectToPlayer(card);
        }
        break;
      case CardType.cure:
        // Implement cure logic as needed
        break;
      case CardType.shield:
        player.shield += card.value;
        GameLogger.info(LogCategory.combat, '\u001b[32m${player.name}\u001b[0m gains ${card.value} shield. Shield: \u001b[36m${player.shield}\u001b[0m');
        break;
      case CardType.shieldAttack:
        // Implement shieldAttack logic as needed
        break;
    }
    // Do not end player turn automatically after playing a card
  }

  void endPlayerTurn() {
    isPlayerTurn = false;
    GameLogger.info(LogCategory.game, 'Player turn ended');
    _discardHand(player);
    _drawHand(player);
  }

  void executeEnemyTurn() {
    if (isPlayerTurn) {
      GameLogger.warning(LogCategory.game, 'Cannot execute enemy turn during player turn');
      return;
    }

    // Process enemy status effects (e.g., poison)
    int? poisonValue = enemy.statusEffects[StatusEffect.poison];
    int? burnValue = enemy.statusEffects[StatusEffect.burn];
    if (poisonValue != null && poisonValue > 0) {
      (CombatSceneLayout.current?.panels[1] as PlayerCombatPanel).showDotEffect(StatusEffect.poison, poisonValue);
    }
    if (burnValue != null && burnValue > 0) {
      (CombatSceneLayout.current?.panels[1] as PlayerCombatPanel).showDotEffect(StatusEffect.burn, 3); // Burn is always 3
    }
    enemy.onTurnStart();
    GameLogger.info(LogCategory.game, 'Enemy turn starting');

    // 1. Select an action using probability if available
    if (enemy.deck.isNotEmpty) {
      final enemyName = enemy.name;
      GameCard? card;
      dynamic pickedAction;
      if (_enemyActionsByName != null && _enemyActionsByName![enemyName] != null) {
        final actions = _enemyActionsByName![enemyName]!;
        // Log all possible actions and their probabilities
        for (final a in actions) {
          GameLogger.info(LogCategory.game, 'Enemy action option: ${a.actionName} (probability: ${a.probability})');
        }
        // Weighted random selection
        final totalProb = actions.fold<double>(0, (sum, a) => sum + (a.probability ?? 0));
        if (totalProb > 0) {
          final random = Random();
          final rand = random.nextDouble() * totalProb;
          GameLogger.info(LogCategory.game, 'Random value for selection: $rand (totalProb: $totalProb)');
          double cumulative = 0;
          for (int i = 0; i < actions.length; i++) {
            cumulative += actions[i].probability;
            GameLogger.info(LogCategory.game, 'Cumulative probability after ${actions[i].actionName}: $cumulative');
            if (rand <= cumulative) {
              pickedAction = actions[i];
              // Find the corresponding GameCard in the deck by name
              card = enemy.deck.firstWhere((c) => c.name == actions[i].actionName, orElse: () => enemy.deck.first);
              break;
            }
          }
        }
      }
      // Fallback: uniform random
      card ??= (enemy.deck..shuffle()).first;
      if (pickedAction != null) {
        GameLogger.info(LogCategory.game, 'Enemy picked action: ${pickedAction.actionName} (probability: ${pickedAction.probability})');
      } else {
        GameLogger.info(LogCategory.game, 'Enemy picked action (fallback): ${card.name}');
      }

      // Store the picked action for UI
      lastEnemyAction = card;

      // 2. Apply effect
      switch (card.type) {
        case CardType.attack:
          playerTakeDamage(card.value);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.damage,
            target: player,
            value: card.value,
            description: '${enemy.name} dealt ${card.value} damage',
            card: card,
          ));
          GameLogger.info(LogCategory.game, 'Dealt ${card.value} damage to ${player.name}');
          break;
        case CardType.heal:
          enemyHeal(card.value);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.heal,
            target: enemy,
            value: card.value,
            description: '${enemy.name} healed for ${card.value}',
            card: card,
          ));
          GameLogger.info(LogCategory.game, 'Healed ${enemy.name} for ${card.value} HP');
          break;
        case CardType.statusEffect:
          if (card.target == "enemy" || card.target == "self") {
            applyStatusEffectToEnemy(card);
          } else if (card.target == "player") {
            applyStatusEffectToPlayer(card);
          }
          break;
        case CardType.cure:
          // Implement cure logic if needed
          break;
        case CardType.shield:
        case CardType.shieldAttack:
          // Implement shield logic if needed
          break;
      }
    }

    isPlayerTurn = true;
    _startNewPlayerTurn();
  }

  void _startNewPlayerTurn() {
    GameLogger.info(LogCategory.game, 'Starting new player turn');
    // Process player status effects (e.g., poison)
    int? poisonValue = player.statusEffects[StatusEffect.poison];
    int? burnValue = player.statusEffects[StatusEffect.burn];
    if (poisonValue != null && poisonValue > 0) {
      (CombatSceneLayout.current?.panels[1] as PlayerCombatPanel).showDotEffect(StatusEffect.poison, poisonValue);
    }
    if (burnValue != null && burnValue > 0) {
      (CombatSceneLayout.current?.panels[1] as PlayerCombatPanel).showDotEffect(StatusEffect.burn, 3); // Burn is always 3
    }
    player.onTurnStart();
    player.currentEnergy = player.maxEnergy;
    _drawHand(player);
    // Implement any logic needed at the start of a new player turn
  }

  bool isCombatOver() {
    // Combat is over if either player or enemy health is 0 or less
    return player.currentHealth <= 0 || enemy.currentHealth <= 0;
  }

  String? getCombatResult() {
    if (player.currentHealth <= 0) {
      return 'Defeat';
    } else if (enemy.currentHealth <= 0) {
      return 'Victory';
    }
    return null;
  }

  // Helper methods for damage/heal (implement as needed)
  void enemyTakeDamage(int value) {
    // Apply shield before HP
    if (enemy.shield > 0) {
      if (enemy.shield >= value) {
        enemy.shield -= value;
        GameLogger.info(LogCategory.combat, '${enemy.name} loses $value shield. Shield: \\${enemy.shield}');
        return;
      } else {
        int remaining = value - enemy.shield;
        GameLogger.info(LogCategory.combat, '${enemy.name} loses \\${enemy.shield} shield. Shield: 0');
        enemy.shield = 0;
        enemy.currentHealth = (enemy.currentHealth - remaining).clamp(0, enemy.maxHealth);
        GameLogger.info(LogCategory.combat, '${enemy.name} takes $remaining damage. Health: \\${enemy.currentHealth}/\\${enemy.maxHealth}');
        return;
      }
    }
    // If no shield
    enemy.currentHealth = (enemy.currentHealth - value).clamp(0, enemy.maxHealth);
    GameLogger.info(LogCategory.combat, '${enemy.name} takes $value damage. Health: \\${enemy.currentHealth}/\\${enemy.maxHealth}');
  }

  void playerHeal(int value) {
    if (player.currentHealth != null) {
      player.currentHealth = (player.currentHealth + value).clamp(0, player.maxHealth);
      GameLogger.info(LogCategory.combat, 'Player heals for $value. Health: \\${player.currentHealth}/\\${player.maxHealth}');
    } else {
      GameLogger.info(LogCategory.combat, 'Player heals for $value');
    }
  }

  // Helper methods for enemy actions
  void playerTakeDamage(int value) {
    // Apply shield before HP
    if (player.shield > 0) {
      if (player.shield >= value) {
        player.shield -= value;
        GameLogger.info(LogCategory.combat, '${player.name} loses $value shield. Shield: \\${player.shield}');
        return;
      } else {
        int remaining = value - player.shield;
        GameLogger.info(LogCategory.combat, '${player.name} loses \\${player.shield} shield. Shield: 0');
        player.shield = 0;
        player.currentHealth = (player.currentHealth - remaining).clamp(0, player.maxHealth);
        GameLogger.info(LogCategory.combat, '${player.name} takes $remaining damage. Health: \\${player.currentHealth}/\\${player.maxHealth}');
        return;
      }
    }
    // If no shield
    player.currentHealth = (player.currentHealth - value).clamp(0, player.maxHealth);
    GameLogger.info(LogCategory.combat, '${player.name} takes $value damage. Health: \\${player.currentHealth}/\\${player.maxHealth}');
  }

  void enemyHeal(int value) {
    // Actually heal the enemy
    if (enemy.currentHealth != null) {
      enemy.currentHealth = (enemy.currentHealth + value).clamp(0, enemy.maxHealth);
      GameLogger.info(LogCategory.combat, 'Enemy heals for $value. Health: ${enemy.currentHealth}/${enemy.maxHealth}');
    } else {
      GameLogger.info(LogCategory.combat, 'Enemy heals for $value');
    }
  }

  // Optionally, implement status effect application for statusEffect cards
  void applyStatusEffectToPlayer(GameCard card) {
    if (card.statusEffectToApply != null && card.statusDuration != null) {
      player.addStatusEffect(card.statusEffectToApply!, card.statusDuration!);
      GameLogger.info(LogCategory.combat, 'Player is affected by [32m${card.statusEffectToApply}[0m for ${card.statusDuration} (stacked if poison)');
      _notifyWatchers(CombatEvent(
        type: CombatEventType.status,
        target: player,
        value: 0,
        description: '${enemy.name} applied ${card.statusEffectToApply} to ${player.name} (x${card.statusDuration})',
        card: card,
      ));
    }
  }

  void applyStatusEffectToEnemy(GameCard card) {
    if (card.statusEffectToApply != null && card.statusDuration != null) {
      enemy.addStatusEffect(card.statusEffectToApply!, card.statusDuration!);
      GameLogger.info(LogCategory.combat, 'Enemy is affected by [32m${card.statusEffectToApply}[0m for ${card.statusDuration} (stacked if poison)');
      _notifyWatchers(CombatEvent(
        type: CombatEventType.status,
        target: enemy,
        value: 0,
        description: '${enemy.name} applied ${card.statusEffectToApply} to self (x${card.statusDuration})',
        card: card,
      ));
    }
  }
} 