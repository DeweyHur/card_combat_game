import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';

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

  void initialize({required GameCharacter player, required GameCharacter enemy}) {
    this.player = player;
    this.enemy = enemy;
    isPlayerTurn = true;
    _watchers.clear();
  }

  void startCombat() {
    GameLogger.info(LogCategory.game, 'Starting combat: ${player.name} vs ${enemy.name}');
    _initializePlayerDeck();
    // Draw initial hand logic can be implemented here if needed
  }

  void _initializePlayerDeck() {
    // Shuffle the player's deck at the start of combat
    player.deck.shuffle();
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
        applyStatusEffectToPlayer(card);
        break;
      case CardType.cure:
        // Implement cure logic as needed
        break;
      case CardType.shield:
      case CardType.shieldAttack:
        // Implement shield logic as needed
        break;
    }
    // Do not end player turn automatically after playing a card
  }

  void endPlayerTurn() {
    isPlayerTurn = false;
    GameLogger.info(LogCategory.game, 'Player turn ended');
  }

  void executeEnemyTurn() {
    if (isPlayerTurn) {
      GameLogger.warning(LogCategory.game, 'Cannot execute enemy turn during player turn');
      return;
    }

    GameLogger.info(LogCategory.game, 'Enemy turn starting');

    // 1. Select an action (e.g., first card or random)
    if (enemy.deck.isNotEmpty) {
      final card = enemy.deck.first; // You can randomize or use probability if desired

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
          // Apply status effect to player
          // You may want to check for nulls
          // For now, just log
          GameLogger.info(LogCategory.game, '${enemy.name} applies status effect to ${player.name}');
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
    player.currentEnergy = player.maxEnergy;
    // Implement any logic needed at the start of a new player turn
  }

  bool isCombatOver() {
    // Implement combat over logic based on player/enemy health
    return false;
  }

  String? getCombatResult() {
    // Implement combat result logic
    return null;
  }

  // Helper methods for damage/heal (implement as needed)
  void enemyTakeDamage(int value) {
    // Implement damage logic
  }

  void playerHeal(int value) {
    // Implement heal logic
  }

  // Helper methods for enemy actions
  void playerTakeDamage(int value) {
    // Actually apply damage to the player
    if (player.currentHealth != null) {
      player.currentHealth = (player.currentHealth - value).clamp(0, player.maxHealth);
      GameLogger.info(LogCategory.combat, 'Player takes $value damage. Health: ${player.currentHealth}/${player.maxHealth}');
    } else {
      GameLogger.info(LogCategory.combat, 'Player takes $value damage');
    }
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
      // Assuming player has statusEffect and statusDuration fields
      player.statusEffect = card.statusEffectToApply;
      player.statusDuration = card.statusDuration;
      GameLogger.info(LogCategory.combat, 'Player is affected by ${card.statusEffectToApply} for ${card.statusDuration} turns');
      _notifyWatchers(CombatEvent(
        type: CombatEventType.status,
        target: player,
        value: 0,
        description: '${enemy.name} applied ${card.statusEffectToApply} to ${player.name}',
        card: card,
      ));
    }
  }
} 