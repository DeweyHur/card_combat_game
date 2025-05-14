import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';

// --- Combat Event System ---
enum CombatEventType { damage, heal, status, cure }

class CombatEvent {
  final CombatEventType type;
  final dynamic target; // Player or Enemy
  final int value;
  final String? description;
  final GameCard? card;

  CombatEvent({
    required this.type,
    required this.target,
    required this.value,
    this.description,
    this.card,
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

  late PlayerBase player;
  late EnemyBase enemy;
  bool isPlayerTurn = true;
  final List<CombatWatcher> _watchers = [];
  final SoundManager _soundManager = SoundManager();

  void initialize({required PlayerBase player, required EnemyBase enemy}) {
    this.player = player;
    this.enemy = enemy;
    isPlayerTurn = true;
    _watchers.clear();
  }

  void startCombat() {
    GameLogger.info(LogCategory.game, 'Starting combat: ${player.name} vs ${enemy.name}');
    _initializePlayerDeck();
    player.drawInitialHand();
  }

  void _initializePlayerDeck() {
    player.deck.clear();
    player.deck.addAll(gameCards);
    player.shuffleDeck();
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

    if (!player.hand.contains(card)) {
      GameLogger.warning(LogCategory.game, 'Card not in hand');
      return;
    }

    GameLogger.info(LogCategory.game, 'Playing card: ${card.name}');

    // Play the card's sound effect
    _soundManager.playCardSound(card.type);

    switch (card.type) {
      case CardType.attack:
        enemy.takeDamage(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.damage,
          target: enemy,
          value: card.value,
          description: 'Player dealt ${card.value} damage',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Dealt ${card.value} damage to ${enemy.name}');
        break;
      case CardType.heal:
        player.heal(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal,
          target: player,
          value: card.value,
          description: 'Player healed for ${card.value}',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Healed ${player.name} for ${card.value} HP');
        break;
      case CardType.statusEffect:
        if (card.statusEffectToApply != null) {
          enemy.addStatusEffect(card.statusEffectToApply!, card.statusDuration ?? 1);
          // Play status effect sound
          _soundManager.playStatusEffectSound(card.statusEffectToApply!);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.status,
            target: enemy,
            value: card.value,
            description: 'Player applied ${card.statusEffectToApply} to ${enemy.name}',
            card: card,
          ));
          GameLogger.info(LogCategory.game, 'Applied ${card.statusEffectToApply} to ${enemy.name}');
        }
        break;
      case CardType.cure:
        player.removeStatusEffect();
        _notifyWatchers(CombatEvent(
          type: CombatEventType.cure,
          target: player,
          value: 0,
          description: 'Player removed all status effects',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Removed all status effects from ${player.name}');
        break;
      case CardType.shield:
        player.addShield(card.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal, // treat as positive effect
          target: player,
          value: card.value,
          description: 'Player gained ${card.value} shield',
          card: card,
        ));
        GameLogger.info(LogCategory.game, 'Gained ${card.value} shield for ${player.name}');
        break;
      case CardType.shieldAttack:
        final shieldValue = player.shield;
        if (shieldValue > 0) {
          enemy.takeDamage(shieldValue);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.damage,
            target: enemy,
            value: shieldValue,
            description: 'Player dealt ${shieldValue} shield attack damage',
            card: card,
          ));
          GameLogger.info(LogCategory.game, 'Dealt ${shieldValue} shield attack damage to ${enemy.name}');
          player.shield = 0;
          GameLogger.info(LogCategory.game, 'Player shield reset to 0 after shield attack');
        } else {
          GameLogger.info(LogCategory.game, 'No shield to use for shield attack');
        }
        break;
    }

    player.playCard(card);
    GameLogger.info(LogCategory.game, 'Card effect applied. Ending player turn.');
    endPlayerTurn();
  }

  void endPlayerTurn() {
    isPlayerTurn = false;
    player.endTurn();
    GameLogger.info(LogCategory.game, 'Player turn ended');
  }

  void executeEnemyTurn() {
    if (isPlayerTurn) {
      GameLogger.warning(LogCategory.game, 'Cannot execute enemy turn during player turn');
      return;
    }

    GameLogger.info(LogCategory.game, 'Enemy turn starting');
    enemy.onTurnStart();
    final action = enemy.getNextAction();
    GameLogger.info(LogCategory.game, 'Enemy action: $action');

    switch (action.type) {
      case CardType.attack:
        player.takeDamage(action.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.damage,
          target: player,
          value: action.value,
          description: 'Enemy dealt ${action.value} damage',
          card: action,
        ));
        GameLogger.info(LogCategory.game, 'Enemy dealt ${action.value} damage to ${player.name}');
        break;
      case CardType.heal:
        enemy.heal(action.value);
        _notifyWatchers(CombatEvent(
          type: CombatEventType.heal,
          target: enemy,
          value: action.value,
          description: 'Enemy healed for ${action.value}',
          card: action,
        ));
        GameLogger.info(LogCategory.game, 'Enemy healed for ${action.value} HP');
        break;
      case CardType.statusEffect:
        if (action.statusEffectToApply != null) {
          player.addStatusEffect(action.statusEffectToApply!, action.statusDuration ?? 1);
          _notifyWatchers(CombatEvent(
            type: CombatEventType.status,
            target: player,
            value: action.value,
            description: 'Enemy applied ${action.statusEffectToApply} to ${player.name}',
            card: action,
          ));
          GameLogger.info(LogCategory.game, 'Enemy applied ${action.statusEffectToApply} to ${player.name}');
        }
        break;
      case CardType.cure:
        enemy.removeStatusEffect();
        _notifyWatchers(CombatEvent(
          type: CombatEventType.cure,
          target: enemy,
          value: 0,
          description: 'Enemy removed all status effects',
          card: action,
        ));
        GameLogger.info(LogCategory.game, 'Enemy removed all status effects');
        break;
      case CardType.shield:
      case CardType.shieldAttack:
        // Enemies do not use shield or shield attack cards by default
        break;
    }

    isPlayerTurn = true;
    _startNewPlayerTurn();
  }

  void _startNewPlayerTurn() {
    GameLogger.info(LogCategory.game, 'Starting new player turn');
    player.startTurn();
  }

  bool isCombatOver() {
    return player.currentHealth <= 0 || enemy.currentHealth <= 0;
  }

  String? getCombatResult() {
    if (player.currentHealth <= 0) {
      return 'You Lost!';
    } else if (enemy.currentHealth <= 0) {
      return 'You Won!';
    }
    return null;
  }
} 