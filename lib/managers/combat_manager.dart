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

    // Implement hand and energy logic as needed
    // For now, just apply the card effect
    GameLogger.info(LogCategory.game, 'Playing card: \'${card.name}\'');
    _soundManager.playCardSound(card.type);

    switch (card.type) {
      case CardType.attack:
        enemyTakeDamage(card.value);
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
        playerHeal(card.value);
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
        // Implement status effect logic as needed
        break;
      case CardType.cure:
        // Implement cure logic as needed
        break;
      case CardType.shield:
      case CardType.shieldAttack:
        // Implement shield logic as needed
        break;
    }

    // End player turn after playing a card
    endPlayerTurn();
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
    // Implement enemy action logic here
    // For now, just end the enemy turn
    isPlayerTurn = true;
    _startNewPlayerTurn();
  }

  void _startNewPlayerTurn() {
    GameLogger.info(LogCategory.game, 'Starting new player turn');
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
} 