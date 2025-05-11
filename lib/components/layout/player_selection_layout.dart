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

class PlayerSelectionLayout extends PositionComponent with HasGameRef, TapCallbacks, VerticalStackMixin {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  late TextComponent titleText;
  late PlayerDetailPanel detailPanel;
  late PlayerSelectionPanel selectionPanel;
  late EnemyPanel enemyPanel;
  late TextComponent battleButton;
  late PlayerBase selectedPlayer;
  late EnemyBase selectedEnemy;

  PlayerSelectionLayout() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = gameRef.size;

    // Initialize selected player and enemy
    selectedPlayer = Knight();
    detailPanel = PlayerDetailPanel(initialPlayer: selectedPlayer);
    selectionPanel = PlayerSelectionPanel()
      ..onPlayerSelected = _handlePlayerSelected;
    final availableEnemies = [
      TungTungTungSahur(),
      TrippiTroppi(),
      TrullimeroTrullicina(),
    ];
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[random];
    enemyPanel = EnemyPanel(enemy: selectedEnemy);

    // Add enemy panel
    addToVerticalStack(enemyPanel, size.y * 0.2);

    // Add title text
    titleText = TextComponent(
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
    addToVerticalStack(titleText, 50);

    // Add detail panel
    addToVerticalStack(detailPanel, size.y * 0.3);

    // Add selection panel
    addToVerticalStack(selectionPanel, size.y * 0.4);

    // Add battle button
    battleButton = TextComponent(
      text: 'Start Battle',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      size: Vector2(200, 20),
      position: Vector2(size.x / 2, 0),
      anchor: Anchor.topCenter,
    );
    addToVerticalStack(battleButton, 60);

    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Optionally, draw a custom background or border for the battle button here
  }

  void _handlePlayerSelected(PlayerBase player) {
    selectedPlayer = player;
    // Update detail panel
    detailPanel.removeFromParent();
    detailPanel = PlayerDetailPanel(player: player);
    detailPanel.position = Vector2(size.x / 2, 0);
    detailPanel.size = Vector2(size.x, 200);
    detailPanel.anchor = Anchor.topCenter;
    addToVerticalStack(detailPanel);
  }

  bool isBattleButtonTappedAt(Vector2 position) {
    final buttonWidth = 200.0;
    final buttonHeight = 60.0;
    final buttonX = size.x / 2 - buttonWidth / 2;
    final buttonY = battleButton.position.y - buttonHeight / 2;
    return position.x >= buttonX &&
           position.x <= buttonX + buttonWidth &&
           position.y >= buttonY &&
           position.y <= buttonY + buttonHeight;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isBattleButtonTappedAt(event.canvasPosition)) {
      GameLogger.info(LogCategory.game, 'Starting battle with \\${selectedPlayer.name} vs \\${selectedEnemy.name}');
      // TODO: Add callback to scene to start battle with selectedPlayer and selectedEnemy
    }
  }
} 