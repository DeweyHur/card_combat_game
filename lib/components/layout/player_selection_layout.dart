import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/player_detail_panel.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/components/panel/enemy_detail_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_character.dart';

class PlayerSelectionLayout extends PositionComponent with HasGameRef, TapCallbacks, VerticalStackMixin {
  late PlayerDetailPanel detailPanel;
  late PlayerSelectionPanel selectionPanel;
  late PositionComponent battleButton;
  late EnemyDetailPanel enemyPanel;

  PlayerSelectionLayout() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = gameRef.size;

    // Ensure a selected player is set before constructing detailPanel
    final players = DataController.instance.get<List<GameCharacter>>('players');
    if (players != null && players.isNotEmpty) {
      final selectedPlayer = DataController.instance.get<GameCharacter>('selectedPlayer');
      if (selectedPlayer == null) {
        DataController.instance.set<GameCharacter>('selectedPlayer', players.first);
      }
    }

    // Now it's safe to construct detailPanel
    detailPanel = PlayerDetailPanel();
    selectionPanel = PlayerSelectionPanel();
    
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
    addToVerticalStack(detailPanel, size.y * 0.17);
    addToVerticalStack(selectionPanel, size.y * 0.2);

    battleButton = PositionComponent(
      size: Vector2(200, 50),
      position: Vector2(size.x / 2, size.y - 40),
      anchor: Anchor.center,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 50),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Start Battle',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(100, 25),
        ),
      );
    add(battleButton);

    enemyPanel = EnemyDetailPanel();
    addToVerticalStack(enemyPanel, size.y * 0.45);

    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (battleButton.toRect().contains(event.localPosition.toOffset())) {
      GameLogger.debug(LogCategory.ui, 'Start Battle button pressed');
      // Just push the combat scene
      SceneManager().pushScene('combat');
    }
  }
} 