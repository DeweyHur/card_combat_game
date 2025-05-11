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
  TextComponent? healthText;
  TextComponent? energyText;
  TextComponent? actionText;
  RectangleComponent? separatorLine;
  bool _isLoaded = false;

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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
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
      anchor: Anchor.center,
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerPanel loading...');

    // Set size and position
    size = Vector2(300, 400);
    anchor = Anchor.center;
    
    GameLogger.info(LogCategory.ui, 'PlayerPanel dimensions:');
    GameLogger.info(LogCategory.ui, '  - Size: ${size.x}x${size.y}');
    GameLogger.info(LogCategory.ui, '  - Position: ${position.x},${position.y}');
    GameLogger.info(LogCategory.ui, '  - Absolute Position: ${absolutePosition.x},${absolutePosition.y}');

    // Set text positions based on panel size
    playerNameText.position = Vector2(0, -size.y * 0.4);
    playerHealthText.position = Vector2(0, -size.y * 0.3);
    playerStatsText.position = Vector2(0, -size.y * 0.2);
    playerEnergyText.position = Vector2(0, -size.y * 0.1);
    playerDeckText.position = Vector2(0, 0);
    playerHandText.position = Vector2(0, size.y * 0.1);
    playerDiscardText.position = Vector2(0, size.y * 0.2);
    playerStatusText.position = Vector2(0, size.y * 0.3);
    
    // Add UI components
    add(playerNameText);
    add(playerHealthText);
    add(playerStatsText);
    add(playerEnergyText);
    add(playerDeckText);
    add(playerHandText);
    add(playerDiscardText);
    add(playerStatusText);

    // Create text components
    healthText = TextComponent(
      text: 'Health: ${player.currentHealth}/${player.maxHealth}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(0, -size.y * 0.3),
      anchor: Anchor.center,
    );
    add(healthText!);
    GameLogger.info(LogCategory.ui, 'Health text position: ${healthText!.position.x},${healthText!.position.y}');

    energyText = TextComponent(
      text: 'Energy: ${player.energy}/${player.maxEnergy}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(0, -size.y * 0.2),
      anchor: Anchor.center,
    );
    add(energyText!);
    GameLogger.info(LogCategory.ui, 'Energy text position: ${energyText!.position.x},${energyText!.position.y}');

    actionText = TextComponent(
      text: 'Next Action: None',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(0, -size.y * 0.1),
      anchor: Anchor.center,
    );
    add(actionText!);
    GameLogger.info(LogCategory.ui, 'Action text position: ${actionText!.position.x},${actionText!.position.y}');

    // Add separator line
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      position: Vector2(0, 0),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
      anchor: Anchor.center,
    );
    add(separatorLine!);
    GameLogger.info(LogCategory.ui, 'Separator line:');
    GameLogger.info(LogCategory.ui, '  - Position: ${separatorLine!.position.x},${separatorLine!.position.y}');
    GameLogger.info(LogCategory.ui, '  - Size: ${separatorLine!.size.x}x${separatorLine!.size.y}');

    _isLoaded = true;
    GameLogger.debug(LogCategory.ui, 'PlayerPanel loaded successfully');
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

    if (_isLoaded) {
      if (healthText != null) {
        healthText!.text = 'Health: ${player.currentHealth}/${player.maxHealth}';
      }
      if (energyText != null) {
        energyText!.text = 'Energy: ${player.energy}/${player.maxEnergy}';
      }
    }
  }

  void updateAction(String action) {
    if (_isLoaded && actionText != null) {
      actionText!.text = 'Next Action: $action';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw panel background
    final paint = Paint()
      ..color = player.color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = player.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
      borderPaint,
    );
  }
} 