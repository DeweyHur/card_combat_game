import 'package:flame/components.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CombatManager {
  final PlayerBase player;
  final EnemyBase enemy;
  bool isPlayerTurn = true;

  CombatManager({
    required this.player,
    required this.enemy,
  });

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

    switch (card.type) {
      case CardType.attack:
        enemy.takeDamage(card.value);
        GameLogger.info(LogCategory.game, 'Dealt ${card.value} damage to ${enemy.name}');
        break;
      case CardType.heal:
        player.heal(card.value);
        GameLogger.info(LogCategory.game, 'Healed ${player.name} for ${card.value} HP');
        break;
      case CardType.statusEffect:
        if (card.statusEffectToApply != null) {
          enemy.addStatusEffect(card.statusEffectToApply!, card.statusDuration ?? 1);
          GameLogger.info(LogCategory.game, 'Applied ${card.statusEffectToApply} to ${enemy.name}');
        }
        break;
      case CardType.cure:
        player.removeStatusEffect();
        GameLogger.info(LogCategory.game, 'Removed all status effects from ${player.name}');
        break;
    }

    player.playCard(card);
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
        GameLogger.info(LogCategory.game, 'Enemy dealt ${action.value} damage to ${player.name}');
        break;
      case CardType.heal:
        enemy.heal(action.value);
        GameLogger.info(LogCategory.game, 'Enemy healed for ${action.value} HP');
        break;
      case CardType.statusEffect:
        if (action.statusEffectToApply != null) {
          player.addStatusEffect(action.statusEffectToApply!, action.statusDuration ?? 1);
          GameLogger.info(LogCategory.game, 'Enemy applied ${action.statusEffectToApply} to ${player.name}');
        }
        break;
      case CardType.cure:
        enemy.removeStatusEffect();
        GameLogger.info(LogCategory.game, 'Enemy removed all status effects');
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