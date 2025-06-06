import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'dart:math';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/enemy.dart';
import 'package:flutter/foundation.dart';
import 'package:card_combat_app/models/game_card.dart';

// --- Combat Event System ---
enum CombatEventType {
  damage,
  heal,
  shield,
  status,
  energy,
  draw,
  discard,
  turnStart,
  turnEnd,
  cardPlayed,
  cardDiscarded,
  cardDrawn,
  cardExhausted,
  cardRefreshed,
  cardUpgraded,
  enemyAction,
  enemyTurn,
  playerTurn,
  combatStart,
  combatEnd,
  victory,
  defeat,
  shieldAttack,
}

class CombatEvent {
  final CombatEventType type;
  final GameCharacter source;
  final GameCharacter target;
  final int? value;
  final StatusEffect? statusEffect;
  final int? statusDuration;
  final CardRun? card;
  final String? description;

  CombatEvent({
    required this.type,
    required this.source,
    required this.target,
    this.value,
    this.statusEffect,
    this.statusDuration,
    this.card,
    this.description,
  });

  @override
  String toString() {
    final parts = <String>[];
    parts.add(type.toString().split('.').last);
    parts.add('from: ${source.name}');
    parts.add('to: ${target.name}');
    if (value != null) parts.add('value: $value');
    if (statusEffect != null)
      parts.add('effect: ${statusEffect.toString().split('.').last}');
    if (statusDuration != null) parts.add('duration: $statusDuration');
    if (card != null) parts.add('card: ${card!.name}');
    if (description != null) parts.add('description: $description');
    return parts.join(', ');
  }
}

abstract class CombatWatcher {
  void onCombatEvent(CombatEvent event);
}
// --- End Combat Event System ---

class CombatManager extends ChangeNotifier {
  static final CombatManager _instance = CombatManager._internal();
  factory CombatManager() => _instance;
  CombatManager._internal();

  late final PlayerRun player;
  late final EnemyRun enemy;
  bool _isCombatOver = false;
  bool isPlayerTurn = true;
  final List<CombatWatcher> _watchers = [];
  final List<CombatEvent> eventHistory = [];

  // Store enemy actions by name for probability-based selection
  Map<String, List<dynamic>>? _enemyActionsByName; // dynamic for EnemyAction
  void setEnemyActionsByName(Map<String, List<dynamic>> actions) {
    _enemyActionsByName = actions;
  }

  // Store the last picked enemy action for UI
  CardRun? lastEnemyAction;

  void initialize({required PlayerRun player, required EnemyRun enemy}) {
    this.player = player;
    this.enemy = enemy;
    _isCombatOver = false;
    isPlayerTurn = true;
    _watchers.clear();
    _discardHand(this.player);
    _drawHand(this.player);
  }

  void startCombat() {
    GameLogger.info(LogCategory.combat,
        'Starting combat between ${player.name} and ${enemy.name}');
    _initializePlayerDeck();
    _discardHand(player);
    _drawHand(player);
    _isCombatOver = false;
    isPlayerTurn = true;
    eventHistory.clear();
    _addEvent(
      CombatEventType.combatStart,
      source: player,
      target: enemy,
    );
    _startPlayerTurn();
  }

  void _initializePlayerDeck() {
    // Shuffle the player's deck at the start of combat
    player.deck.shuffle();
  }

  void _drawHand(GameCharacter character) {
    if (character is PlayerRun) {
      while (character.hand.length < character.handSize &&
          character.deck.isNotEmpty) {
        character.hand.add(character.deck.removeAt(0));
      }
    }
  }

  void _discardHand(GameCharacter character) {
    if (character is PlayerRun) {
      character.hand.clear();
    }
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

  void playCard(CardRun card) {
    if (!isPlayerTurn || _isCombatOver) return;

    // Check if player has enough energy
    if (player.currentEnergy < card.cost) {
      GameLogger.info(LogCategory.combat,
          'Not enough energy to play ${card.name} (${player.currentEnergy}/${card.cost})');
      return;
    }

    // Deduct energy cost
    player.currentEnergy -= card.cost;

    // Handle card effects based on type
    switch (card.type) {
      case CardType.attack:
        enemy.takeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.damage,
          source: player,
          target: enemy,
          value: card.value,
          card: card,
        ));
        break;

      case CardType.heal:
        player.heal(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal,
          source: player,
          target: player,
          value: card.value,
          card: card,
        ));
        break;

      case CardType.statusEffect:
        if (card.statusEffectToApply != null && card.statusDuration != null) {
          enemy.addStatusEffect(
              card.statusEffectToApply!, card.statusDuration!);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.status,
            source: player,
            target: enemy,
            value: card.statusDuration!,
            statusEffect: card.statusEffectToApply,
            statusDuration: card.statusDuration,
            card: card,
          ));
        }
        break;

      case CardType.shield:
        player.addShield(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.shield,
          source: player,
          target: player,
          value: card.value,
          card: card,
        ));
        break;

      case CardType.shieldAttack:
        player.addShield(card.value);
        enemy.takeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.shieldAttack,
          source: player,
          target: enemy,
          value: card.value,
          card: card,
        ));
        break;

      case CardType.cure:
        player.clearStatusEffects();
        _notifyWatchers(CombatEvent(
          type: CombatEventType.status,
          source: player,
          target: player,
          value: 0,
          card: card,
        ));
        break;
    }

    // Move card to discard pile
    player.hand.remove(card);
    player.discardPile.add(card);
    card.exhaust();

    // Check if combat is over
    if (enemy.currentHealth <= 0) {
      _isCombatOver = true;
      _notifyWatchers(CombatEvent(
        type: CombatEventType.damage,
        source: player,
        target: enemy,
        value: 0,
        card: card,
      ));
      _addEvent(
        CombatEventType.victory,
        source: player,
        target: enemy,
      );
    } else if (player.currentHealth <= 0) {
      _isCombatOver = true;
      _notifyWatchers(CombatEvent(
        type: CombatEventType.damage,
        source: enemy,
        target: player,
        value: 0,
        card: card,
      ));
      _addEvent(
        CombatEventType.defeat,
        source: enemy,
        target: player,
      );
    }
  }

  void endTurn() {
    if (_isCombatOver) return;

    isPlayerTurn = false;
    _notifyWatchers(CombatEvent(
      type: CombatEventType.energy,
      source: player,
      target: player,
      value: 0,
      description: '${player.name} ends their turn',
      card: CardRun(CardSetup(CardTemplate.findByName('End Turn')!)),
    ));

    // Enemy turn
    _enemyTurn();

    // Start player's turn
    isPlayerTurn = true;
    player.currentEnergy = player.maxEnergy;
    _notifyWatchers(CombatEvent(
      type: CombatEventType.energy,
      source: player,
      target: player,
      value: player.maxEnergy,
      description: '${player.name} starts their turn',
      card: CardRun(CardSetup(CardTemplate.findByName('Start Turn')!)),
    ));

    // Draw new hand
    _discardHand(player);
    _drawHand(player);
  }

  void _enemyTurn() {
    if (_isCombatOver) return;

    // Get enemy actions for this enemy
    final actions = _enemyActionsByName?[enemy.name];
    if (actions == null || actions.isEmpty) {
      GameLogger.error(
          LogCategory.combat, 'No actions found for enemy ${enemy.name}');
      return;
    }

    // Pick a random action based on probability
    final random = Random();
    final totalWeight = actions.fold<int>(
        0, (sum, action) => sum + (action['probability'] as int));
    var roll = random.nextInt(totalWeight);
    dynamic selectedAction;
    for (final action in actions) {
      roll -= action['probability'] as int;
      if (roll < 0) {
        selectedAction = action;
        break;
      }
    }

    if (selectedAction == null) {
      GameLogger.error(LogCategory.combat,
          'Failed to select action for enemy ${enemy.name}');
      return;
    }

    // Convert action to CardRun
    final cardTemplate =
        CardTemplate.findByName(selectedAction['name'] as String);
    if (cardTemplate == null) {
      GameLogger.error(LogCategory.combat,
          'Card template not found for action: ${selectedAction['name']}');
      return;
    }
    final cardSetup = CardSetup(cardTemplate);
    final card = CardRun(cardSetup);
    lastEnemyAction = card;

    // Execute the action
    switch (card.type) {
      case CardType.attack:
        player.takeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.damage,
          source: enemy,
          target: player,
          value: card.value,
          description: '${player.name} takes ${card.value} damage',
          card: card,
        ));
        break;

      case CardType.heal:
        enemy.heal(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal,
          source: enemy,
          target: enemy,
          value: card.value,
          description: '${enemy.name} heals for ${card.value}',
          card: card,
        ));
        break;

      case CardType.statusEffect:
        if (card.statusEffectToApply != null && card.statusDuration != null) {
          player.addStatusEffect(
              card.statusEffectToApply!, card.statusDuration!);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.status,
            source: enemy,
            target: player,
            value: card.statusDuration!,
            description:
                '${player.name} is affected by ${card.statusEffectToApply} for ${card.statusDuration} turns',
            card: card,
          ));
        }
        break;

      case CardType.shield:
        enemy.addShield(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.shield,
          source: enemy,
          target: enemy,
          value: card.value,
          description: '${enemy.name} gains ${card.value} shield',
          card: card,
        ));
        break;

      case CardType.shieldAttack:
        enemy.addShield(card.value);
        player.takeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.shieldAttack,
          source: enemy,
          target: player,
          value: card.value,
          description:
              '${enemy.name} gains ${card.value} shield and deals ${card.value} damage',
          card: card,
        ));
        break;

      case CardType.cure:
        enemy.clearStatusEffects();
        _notifyWatchers(CombatEvent(
          type: CombatEventType.status,
          source: enemy,
          target: enemy,
          value: 0,
          description: '${enemy.name} is cured of all status effects',
          card: card,
        ));
        break;
    }

    // Check if combat is over
    if (enemy.currentHealth <= 0) {
      _isCombatOver = true;
      _notifyWatchers(CombatEvent(
        type: CombatEventType.damage,
        source: player,
        target: enemy,
        value: 0,
        description: '${enemy.name} is defeated!',
        card: card,
      ));
    } else if (player.currentHealth <= 0) {
      _isCombatOver = true;
      _notifyWatchers(CombatEvent(
        type: CombatEventType.damage,
        source: enemy,
        target: player,
        value: 0,
        description: '${player.name} is defeated!',
        card: card,
      ));
    }
  }

  void applyStatusEffectToPlayer(CardRun card) {
    if (card.statusEffectToApply != null && card.statusDuration != null) {
      player.addStatusEffect(card.statusEffectToApply!, card.statusDuration!);
      _notifyWatchers(CombatEvent(
        type: CombatEventType.status,
        source: enemy,
        target: player,
        value: card.statusDuration!,
        description:
            '${player.name} is affected by ${card.statusEffectToApply} for ${card.statusDuration} turns',
        card: card,
      ));
    }
  }

  void applyStatusEffectToEnemy(CardRun card) {
    if (card.statusEffectToApply != null && card.statusDuration != null) {
      enemy.addStatusEffect(card.statusEffectToApply!, card.statusDuration!);
      _notifyWatchers(CombatEvent(
        type: CombatEventType.status,
        source: player,
        target: enemy,
        value: card.statusDuration!,
        description:
            '${enemy.name} is affected by ${card.statusEffectToApply} for ${card.statusDuration} turns',
        card: card,
      ));
    }
  }

  void update() {
    // Process status effects that need to be updated every frame
    if (player.statusEffects.containsKey(StatusEffect.regeneration)) {
      player.heal(1);
    }
    if (enemy.statusEffects.containsKey(StatusEffect.regeneration)) {
      enemy.heal(1);
    }
  }

  bool isCombatOver() {
    return _isCombatOver;
  }

  String? getCombatResult() {
    if (player.currentHealth <= 0) {
      return 'Defeat';
    } else if (enemy.currentHealth <= 0) {
      // Get all enemies from DataController
      final enemies = DataController.instance.get<List<EnemyRun>>('enemies');
      if (enemies != null && enemies.isNotEmpty) {
        // Find the current enemy's index
        final currentIndex = enemies.indexWhere((e) => e.name == enemy.name);
        if (currentIndex != -1 && currentIndex < enemies.length - 1) {
          // Set the next enemy in sequence
          DataController.instance.set('nextEnemy', enemies[currentIndex + 1]);
        } else {
          // If this was the last enemy, set the first enemy as next
          DataController.instance.set('nextEnemy', enemies[0]);
        }
      }
      return 'Victory';
    }
    return null;
  }

  void _startPlayerTurn() {
    player.startTurn();
    _notifyWatchers(CombatEvent(
      type: CombatEventType.playerTurn,
      source: player,
      target: player,
      value: player.maxEnergy,
      card: CardRun(CardSetup(CardTemplate.findByName('Start Turn')!)),
    ));
  }

  void _addEvent(CombatEventType type,
      {required GameCharacter source,
      required GameCharacter target,
      int? value,
      StatusEffect? statusEffect,
      int? statusDuration,
      CardRun? card}) {
    final event = CombatEvent(
      type: type,
      source: source,
      target: target,
      value: value,
      statusEffect: statusEffect,
      statusDuration: statusDuration,
      card: card,
    );
    eventHistory.add(event);
    GameLogger.debug(LogCategory.combat, 'Combat event: $event');
    notifyListeners();
  }

  // Helper methods for damage/heal (implement as needed)
  void enemyTakeDamage(int value) {
    // Apply shield before HP
    if (enemy.currentShield > 0) {
      if (enemy.currentShield >= value) {
        enemy.currentShield -= value;
        GameLogger.info(LogCategory.combat,
            '${enemy.name} loses $value shield. Shield: ${enemy.currentShield}');
        return;
      } else {
        int remaining = value - enemy.currentShield;
        GameLogger.info(LogCategory.combat,
            '${enemy.name} loses ${enemy.currentShield} shield. Shield: 0');
        enemy.currentShield = 0;
        enemy.currentHealth =
            (enemy.currentHealth - remaining).clamp(0, enemy.maxHealth);
        GameLogger.info(LogCategory.combat,
            '${enemy.name} takes $remaining damage. Health: ${enemy.currentHealth}/${enemy.maxHealth}');
        return;
      }
    }
    // If no shield
    enemy.currentHealth =
        (enemy.currentHealth - value).clamp(0, enemy.maxHealth);
    GameLogger.info(LogCategory.combat,
        '${enemy.name} takes $value damage. Health: ${enemy.currentHealth}/${enemy.maxHealth}');
  }

  void playerHeal(int value) {
    player.currentHealth =
        (player.currentHealth + value).clamp(0, player.maxHealth);
    GameLogger.info(LogCategory.combat,
        'Player heals for $value. Health: ${player.currentHealth}/${player.maxHealth}');
  }

  // Helper methods for enemy actions
  void playerTakeDamage(int value) {
    // Apply shield before HP
    if (player.currentShield > 0) {
      if (player.currentShield >= value) {
        player.currentShield -= value;
        GameLogger.info(LogCategory.combat,
            '${player.name} loses $value shield. Shield: ${player.currentShield}');
        return;
      } else {
        int remaining = value - player.currentShield;
        GameLogger.info(LogCategory.combat,
            '${player.name} loses ${player.currentShield} shield. Shield: 0');
        player.currentShield = 0;
        player.currentHealth =
            (player.currentHealth - remaining).clamp(0, player.maxHealth);
        GameLogger.info(LogCategory.combat,
            '${player.name} takes $remaining damage. Health: ${player.currentHealth}/${player.maxHealth}');
        return;
      }
    }
    // If no shield
    player.currentHealth =
        (player.currentHealth - value).clamp(0, player.maxHealth);
    GameLogger.info(LogCategory.combat,
        '${player.name} takes $value damage. Health: ${player.currentHealth}/${player.maxHealth}');
  }

  void enemyHeal(int value) {
    enemy.currentHealth =
        (enemy.currentHealth + value).clamp(0, enemy.maxHealth);
    GameLogger.info(LogCategory.combat,
        'Enemy heals for $value. Health: ${enemy.currentHealth}/${enemy.maxHealth}');
  }

  void endCombat() {
    _isCombatOver = true;
    _addEvent(
      CombatEventType.combatEnd,
      source: player,
      target: enemy,
    );
  }
}
