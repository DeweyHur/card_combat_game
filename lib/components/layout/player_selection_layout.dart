import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
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
  late PlayerDetailPanel detailPanel;
  late PlayerSelectionPanel selectionPanel;
  late EnemyPanel enemyPanel;
  late TextComponent battleButton;
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
    detailPanel = PlayerDetailPanel();
    selectionPanel = PlayerSelectionPanel();
    final availableEnemies = [
      TungTungTungSahur(),
      TrippiTroppi(),
      TrullimeroTrullicina(),
    ];
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[random];
    enemyPanel = EnemyPanel(enemy: selectedEnemy);
    
    addToVerticalStack(enemyPanel, size.y * 0.2);
    addToVerticalStack(TextComponent(
      text: 'Select Your Character',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      size: Vector2(size.x, 50),
    ), 50);
    addToVerticalStack(detailPanel, size.y * 0.3);
    addToVerticalStack(selectionPanel, size.y * 0.2);

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
      anchor: Anchor.bottomCenter,
    );
    add(battleButton);

    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }
} 