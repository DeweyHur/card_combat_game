import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/components/layout/game_ui.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'base_scene.dart';

class CombatScene extends BaseScene {
  final PlayerBase player;
  final EnemyBase enemy;
  late List<GameCard> playerDeck;
  late List<GameCard> playerHand;
  late List<GameCard> discardPile;
  bool isPlayerTurn = true;
  late TextComponent turnText;
  late TextComponent enemyNextActionText;

  CombatScene({
    required this.player,
    required this.enemy,
  }) : super(
    backgroundColor: const Color(0xFF1A1A2E),
  );

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Handle tap events here
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'CombatScene loading...');

    // Initialize game areas
    _createGameAreas();

    // Initialize UI
    _createUI();

    // Initialize player's deck
    playerDeck = List.from(gameCards);
    playerHand = [];
    discardPile = [];

    // Update UI with initial values
    _updateUI();

    // Draw initial hand
    _drawInitialHand();

    GameLogger.info(LogCategory.game, 'Combat started: ${player.name} vs ${enemy.name}');
  }

  void _createGameAreas() {
    // Remove the old game areas since we're using GameUI now
    // The GameUI component will handle the layout
  }

  void _createUI() {
    // Remove the old UI components since we're using GameUI now
    // The GameUI component will handle the UI elements
  }

  void _drawInitialHand() {
    for (int i = 0; i < 3; i++) {
      if (playerDeck.isNotEmpty) {
        final card = playerDeck.removeLast();
        playerHand.add(card);
        _addCardToHand(card, i);
      }
    }
    GameLogger.info(LogCategory.game, 'Initial hand drawn: ${playerHand.length} cards');
  }

  void _addCardToHand(GameCard card, int index) {
    final cardWidth = CardsPanel.cardWidth;
    final cardHeight = CardsPanel.cardHeight;
    
    // Calculate position using the CardsPanel's helper method
    final position = (game as CardCombatGame).gameUI.cardsPanel.calculateCardPosition(index);
    
    final cardComponent = CardVisualComponent(
      card,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: executeCard,
      enabled: isPlayerTurn,
    );
    
    // Add card to the game's cards panel
    (game as CardCombatGame).gameUI.cardsPanel.add(cardComponent);
  }

  void executeCard(GameCard card) {
    if (!isPlayerTurn) return;

    GameLogger.info(LogCategory.game, 'Executing card: ${card.name}');

    switch (card.type) {
      case CardType.attack:
        enemy.takeDamage(card.value);
        GameLogger.info(LogCategory.game, 'Dealt ${card.value} damage to ${enemy.name}');
        (game as CardCombatGame).gameUI.updateEnemyHp(enemy.currentHealth, enemy.maxHealth);
        break;
      case CardType.heal:
        player.heal(card.value);
        GameLogger.info(LogCategory.game, 'Healed ${player.name} for ${card.value} HP');
        (game as CardCombatGame).gameUI.updatePlayerHp(player.currentHealth, player.maxHealth);
        break;
      case CardType.statusEffect:
        if (card.statusEffectToApply != null) {
          enemy.addStatusEffect(card.statusEffectToApply!, card.statusDuration);
          GameLogger.info(LogCategory.game, 'Applied ${card.statusEffectToApply} to ${enemy.name}');
        }
        break;
      case CardType.cure:
        player.removeAllStatusEffects();
        GameLogger.info(LogCategory.game, 'Removed all status effects from ${player.name}');
        break;
    }

    // Move card to discard pile
    playerHand.remove(card);
    discardPile.add(card);

    // Update UI
    _updateUI();

    // Check if combat is over
    if (enemy.currentHealth <= 0) {
      _endCombat(true);
      return;
    }

    // End player's turn
    isPlayerTurn = false;
    _executeEnemyTurn();
  }

  void _executeEnemyTurn() {
    GameLogger.info(LogCategory.game, 'Enemy turn starting');
    turnText.text = "${enemy.name}'s Turn";

    // Execute enemy's next action
    final action = enemy.getNextAction();
    GameLogger.info(LogCategory.game, 'Enemy action: $action');

    switch (action.type) {
      case CardType.attack:
        player.takeDamage(action.value);
        GameLogger.info(LogCategory.game, 'Enemy dealt ${action.value} damage to ${player.name}');
        (game as CardCombatGame).gameUI.updatePlayerHp(player.currentHealth, player.maxHealth);
        break;
      case CardType.heal:
        enemy.heal(action.value);
        GameLogger.info(LogCategory.game, 'Enemy healed for ${action.value} HP');
        (game as CardCombatGame).gameUI.updateEnemyHp(enemy.currentHealth, enemy.maxHealth);
        break;
      case CardType.statusEffect:
        if (action.statusEffectToApply != null) {
          player.addStatusEffect(action.statusEffectToApply!, action.statusDuration);
          GameLogger.info(LogCategory.game, 'Enemy applied ${action.statusEffectToApply} to ${player.name}');
        }
        break;
      case CardType.cure:
        enemy.removeAllStatusEffects();
        GameLogger.info(LogCategory.game, 'Enemy removed all status effects');
        break;
    }

    // Update UI
    _updateUI();

    // Check if combat is over
    if (player.currentHealth <= 0) {
      _endCombat(false);
      return;
    }

    // Start new player turn
    _startNewPlayerTurn();
  }

  void _startNewPlayerTurn() {
    GameLogger.info(LogCategory.game, 'Starting new player turn');
    isPlayerTurn = true;
    turnText.text = "Player's Turn";

    // Draw a new card if deck has cards
    if (playerDeck.isNotEmpty) {
      final card = playerDeck.removeLast();
      playerHand.add(card);
      _addCardToHand(card, playerHand.length - 1);
      GameLogger.info(LogCategory.game, 'Drew new card: ${card.name}');
    } else if (discardPile.isNotEmpty) {
      // Reshuffle discard pile if deck is empty
      playerDeck = List.from(discardPile);
      discardPile.clear();
      playerDeck.shuffle();
      GameLogger.info(LogCategory.game, 'Reshuffled discard pile into deck');
    }

    // Update enemy's next action
    enemyNextActionText.text = 'Next: ${enemy.getNextAction()}';
  }

  void _updateUI() {
    // Update enemy's next action
    enemyNextActionText.text = 'Next: ${enemy.getNextAction()}';
    
    // Update HP displays
    (game as CardCombatGame).gameUI.updateEnemyHp(enemy.currentHealth, enemy.maxHealth);
    (game as CardCombatGame).gameUI.updatePlayerHp(player.currentHealth, player.maxHealth);
  }

  void _endCombat(bool playerWon) {
    GameLogger.info(LogCategory.game, 'Combat ended: ${playerWon ? "Player won" : "Enemy won"}');
    (game as CardCombatGame).gameUI.showGameMessage(playerWon ? 'Victory!' : 'Defeat!');
  }
} 