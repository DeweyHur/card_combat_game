import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';

class PlayerPanel extends BasePanel {
  final TextComponent playerNameText;
  final TextComponent playerHealthText;
  final TextComponent playerStatsText;
  final TextComponent playerEnergyText;
  final TextComponent playerDeckText;
  final TextComponent playerHandText;
  final TextComponent playerDiscardText;
  final TextComponent playerStatusText;
  final PlayerBase player;
  late CombatManager combatManager;

  PlayerPanel({
    required this.player,
  }) : 
    playerNameText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
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
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerStatsText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerEnergyText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerDeckText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerHandText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerDiscardText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ),
    playerStatusText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set text positions based on panel size
    playerNameText.position = Vector2(size.x * 0.05, size.y * 0.05);
    playerHealthText.position = Vector2(size.x * 0.05, size.y * 0.15);
    playerStatsText.position = Vector2(size.x * 0.05, size.y * 0.25);
    playerEnergyText.position = Vector2(size.x * 0.05, size.y * 0.35);
    playerDeckText.position = Vector2(size.x * 0.05, size.y * 0.45);
    playerHandText.position = Vector2(size.x * 0.05, size.y * 0.55);
    playerDiscardText.position = Vector2(size.x * 0.05, size.y * 0.65);
    playerStatusText.position = Vector2(size.x * 0.05, size.y * 0.75);
    
    // Add UI components
    add(playerNameText);
    add(playerHealthText);
    add(playerStatsText);
    add(playerEnergyText);
    add(playerDeckText);
    add(playerHandText);
    add(playerDiscardText);
    add(playerStatusText);
  }

  void initialize(PlayerBase player, CombatManager combatManager) {
    this.combatManager = combatManager;
    updateUI();
  }

  @override
  void updateUI() {
    if (combatManager == null) return;
    
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