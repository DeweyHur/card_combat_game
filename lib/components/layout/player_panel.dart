import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class PlayerPanel extends PositionComponent {
  final TextComponent playerNameText;
  final TextComponent playerHealthText;
  final TextComponent playerStatsText;
  final TextComponent playerEnergyText;
  final TextComponent playerDeckText;
  final TextComponent playerHandText;
  final TextComponent playerDiscardText;
  final TextComponent playerStatusText;
  late RectangleComponent background;

  late CombatManager combatManager;

  PlayerPanel({
    required Vector2 position,
    required Vector2 size,
    required PlayerBase player,
    required Function(GameCard) onCardPlayed,
  }) : 
    playerNameText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.05),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    playerHealthText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.15),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerStatsText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.25),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerEnergyText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.35),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerDeckText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.45),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerHandText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.55),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerDiscardText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.65),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerStatusText = TextComponent(
      text: '',
      position: Vector2(size.x * 0.05, size.y * 0.75),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue.withOpacity(0.3),
    );
    add(background);
    
    // Add UI components
    add(playerNameText);
    add(playerHealthText);
    add(playerStatsText);
    add(playerEnergyText);
    add(playerDeckText);
    add(playerHandText);
    add(playerDiscardText);
    add(playerStatusText);
    
    GameLogger.info(LogCategory.ui, 'PlayerPanel mounted at position ${position.x},${position.y} with size ${size.x}x${size.y}');
  }

  void initialize(PlayerBase player, CombatManager combatManager) {
    this.combatManager = combatManager;
    updateUI(combatManager);
  }

  void updateUI(CombatManager combatManager) {
    final player = combatManager.player;
    
    // Update player info
    playerNameText.text = '${player.name} ${player.emoji}';
    playerHealthText.text = 'HP: ${player.currentHealth}/${player.maxHealth}';
    playerStatsText.text = 'ATK: ${player.attack} | DEF: ${player.defense}';
    playerEnergyText.text = 'Energy: ${player.energy}/${player.maxEnergy}';
    playerDeckText.text = 'Deck: ${player.deck.length} cards';
    playerHandText.text = 'Hand: ${player.hand.length} cards';
    playerDiscardText.text = 'Discard: ${player.discardPile.length} cards';
    playerStatusText.text = combatManager.isPlayerTurn ? 'Your Turn' : 'Opponent\'s Turn';
  }
} 