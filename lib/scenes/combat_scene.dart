import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/player/player.dart';
import 'package:card_combat_app/models/enemies/goblin.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'base_scene.dart';

class CombatScene extends BaseScene {
  final Character player;
  final Character enemy;
  late List<GameCard> playerDeck;
  late List<GameCard> playerHand;
  late List<GameCard> discardPile;
  bool isPlayerTurn = true;

  // UI Components
  late TextComponent playerHealthText;
  late TextComponent enemyHealthText;
  late TextComponent turnText;
  late TextComponent enemyNextActionText;

  CombatScene({
    required FlameGame game,
    required this.player,
    required this.enemy,
    super.backgroundColor = Colors.black,
  }) : super(game: game) {
    playerDeck = List.from(gameCards);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize game areas
    _createGameAreas();

    // Initialize UI
    _createUI();

    // Initialize player's deck
    playerDeck.shuffle();
    playerHand = [];
    discardPile = [];

    // Draw initial hand
    _drawInitialHand();

    GameLogger.info(LogCategory.game, 'Combat started: ${player.name} vs ${enemy.name}');
  }

  void _createGameAreas() {
    // Player area (bottom)
    final playerArea = RectangleComponent(
      size: Vector2(game.size.x, game.size.y * 0.4),
      position: Vector2(0, game.size.y * 0.6),
      paint: Paint()..color = Colors.blue.withOpacity(0.1),
    );
    add(playerArea);

    // Enemy area (top)
    final enemyArea = RectangleComponent(
      size: Vector2(game.size.x, game.size.y * 0.4),
      position: Vector2(0, 0),
      paint: Paint()..color = Colors.red.withOpacity(0.1),
    );
    add(enemyArea);

    // Center area (for effects, etc.)
    final centerArea = RectangleComponent(
      size: Vector2(game.size.x, game.size.y * 0.2),
      position: Vector2(0, game.size.y * 0.4),
      paint: Paint()..color = Colors.grey.withOpacity(0.1),
    );
    add(centerArea);
  }

  void _createUI() {
    // Player health display
    playerHealthText = TextComponent(
      text: '${player.name}: ${player.currentHealth}/${player.maxHealth} HP',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      position: Vector2(20, game.size.y * 0.6 + 20),
    );
    add(playerHealthText);

    // Enemy health display
    enemyHealthText = TextComponent(
      text: '${enemy.name}: ${enemy.currentHealth}/${enemy.maxHealth} HP',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      position: Vector2(20, 20),
    );
    add(enemyHealthText);

    // Turn indicator
    turnText = TextComponent(
      text: "Player's Turn",
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(game.size.x / 2, game.size.y * 0.4),
      anchor: Anchor.center,
    );
    add(turnText);

    // Enemy next action display
    enemyNextActionText = TextComponent(
      text: 'Next: ${enemy.getNextAction()}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(game.size.x - 20, 20),
      anchor: Anchor.topRight,
    );
    add(enemyNextActionText);
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
    final cardWidth = 140.0;
    final cardHeight = 180.0;
    
    // Calculate position: start at 5, add 140 for each card
    final position = Vector2(
      5 + (index * 140),
      60, // Position cards relative to the cards panel
    );
    
    GameLogger.info(LogCategory.ui, 'Card ${index + 1} Position: (${position.x}, ${position.y})');
    
    final cardComponent = CardVisualComponent(
      card,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: _executeCard,
      enabled: isPlayerTurn,
    );
    
    // Add card to the game's cards panel
    (game as CardCombatGame).gameUI.cardsPanel.add(cardComponent);
  }

  void _executeCard(GameCard card) {
    if (!isPlayerTurn) return;

    GameLogger.info(LogCategory.game, 'Executing card: ${card.name}');

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
        break;
      case CardType.heal:
        enemy.heal(action.value);
        GameLogger.info(LogCategory.game, 'Enemy healed for ${action.value} HP');
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
    playerHealthText.text = '${player.name}: ${player.currentHealth}/${player.maxHealth} HP';
    enemyHealthText.text = '${enemy.name}: ${enemy.currentHealth}/${enemy.maxHealth} HP';
  }

  void _endCombat(bool playerWon) {
    GameLogger.info(LogCategory.game, 'Combat ended: ${playerWon ? "Player won" : "Enemy won"}');
    // TODO: Implement combat end logic (rewards, scene transition, etc.)
  }
} 