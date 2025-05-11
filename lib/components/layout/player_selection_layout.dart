import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/mage.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/enemies/tung_tung_tung_sahur.dart';
import 'package:card_combat_app/models/enemies/trippi_troppi.dart';
import 'package:card_combat_app/models/enemies/trullimero_trullicina.dart';
import 'package:card_combat_app/components/layout/player_selection_box.dart';
import 'package:card_combat_app/components/panel/player_detail_panel.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/components/panel/enemy_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/panel/player_panel.dart';
import 'package:card_combat_app/components/ui/battle_button.dart';

class PlayerSelectionLayout extends PositionComponent with HasGameRef, TapCallbacks, VerticalStackMixin {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  late final TextComponent titleText;
  late final PlayerDetailPanel detailPanel;
  late final PlayerSelectionPanel selectionPanel;
  late final EnemyPanel enemyPanel;
  late final TextComponent battleButton;
  PlayerBase selectedPlayer;
  late EnemyBase selectedEnemy;

  PlayerSelectionLayout() : super(
    anchor: Anchor.topLeft,
  ) : selectedPlayer = Knight() {
    detailPanel = PlayerDetailPanel(player: selectedPlayer);
    selectionPanel = PlayerSelectionPanel()
      ..onPlayerSelected = _handlePlayerSelected;
    
    // Randomly select an enemy
    final availableEnemies = [
      TungTungTungSahur(),
      TrippiTroppi(),
      TrullimeroTrullicina(),
    ];
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[random];
    enemyPanel = EnemyPanel(enemy: selectedEnemy);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = gameRef.size;

    // Add enemy panel
    enemyPanel.position = Vector2(size.x / 2, 0);
    enemyPanel.size = Vector2(size.x, 400);
    enemyPanel.anchor = Anchor.topCenter;
    addToVerticalStack(enemyPanel);

    // Add title text
    final titleText = TextComponent(
      text: 'Select Your Character',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      size: Vector2(size.x, 50),
    );
    addToVerticalStack(titleText);

    // Add detail panel
    final detailPanel = PlayerPanel(
      size: Vector2(size.x, 200),
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.topCenter,
    );
    addToVerticalStack(detailPanel);

    // Add selection panel
    final selectionPanel = PlayerSelectionPanel(
      size: Vector2(size.x, 300),
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.topCenter,
    );
    addToVerticalStack(selectionPanel);

    // Add battle button
    final battleButton = BattleButton(
      size: Vector2(200, 50),
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.topCenter,
    );
    addToVerticalStack(battleButton);
    
    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw battle button background
    final buttonWidth = 200.0;
    final buttonHeight = 60.0;
    final buttonX = size.x / 2 - buttonWidth / 2;
    final buttonY = size.y * 0.9 - buttonHeight / 2;

    final buttonPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight),
      buttonPaint,
    );

    // Draw button border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight),
      borderPaint,
    );
  }

  void _handlePlayerSelected(PlayerBase player) {
    selectedPlayer = player;
    
    // Update detail panel
    detailPanel.removeFromParent();
    detailPanel = PlayerDetailPanel(player: player);
    detailPanel.position = Vector2(size.x * 0.7, size.y * 0.3);
    addToVerticalStack(detailPanel);
  }

  bool isBattleButtonTappedAt(Vector2 position) {
    final buttonWidth = 200.0;
    final buttonHeight = 60.0;
    final buttonX = size.x / 2 - buttonWidth / 2;
    final buttonY = size.y * 0.9 - buttonHeight / 2;

    return position.x >= buttonX &&
           position.x <= buttonX + buttonWidth &&
           position.y >= buttonY &&
           position.y <= buttonY + buttonHeight;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isBattleButtonTappedAt(event.canvasPosition)) {
      GameLogger.info(LogCategory.game, 'Starting battle with ${selectedPlayer.name} vs ${selectedEnemy.name}');
      // TODO: Add callback to scene to start battle with selectedPlayer and selectedEnemy
    }
  }
} 