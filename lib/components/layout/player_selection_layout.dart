import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/player_detail_panel.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/components/panel/enemy_detail_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

class PlayerSelectionLayout extends PositionComponent
    with HasGameReference, TapCallbacks, VerticalStackMixin {
  late PlayerDetailPanel detailPanel;
  late PlayerSelectionPanel selectionPanel;
  late PositionComponent battleButton;
  late EnemyDetailPanel enemyPanel;
  late PositionComponent backButton;

  PlayerSelectionLayout() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = findGame()!.size;

    // Now it's safe to construct detailPanel
    detailPanel = PlayerDetailPanel();
    selectionPanel = PlayerSelectionPanel();

    registerVerticalStackComponent(
        'selectText',
        TextComponent(
          text: 'Select Your Character',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          size: Vector2(size.x, 50),
        ),
        50);
    registerVerticalStackComponent('detailPanel', detailPanel, size.y * 0.17);
    registerVerticalStackComponent(
        'selectionPanel', selectionPanel, size.y * 0.2);

    // Place Back and Start Battle buttons in one line at the bottom
    final buttonY = size.y - 60;
    backButton = PositionComponent(
      size: Vector2(160, 48),
      position: Vector2(20, buttonY),
      anchor: Anchor.topLeft,
    )
      ..add(RectangleComponent(
        size: Vector2(160, 48),
        paint: Paint()..color = Colors.grey.shade800,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Back',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(80, 24),
        ),
      );
    add(backButton);

    battleButton = PositionComponent(
      size: Vector2(200, 48),
      position: Vector2(size.x - 220, buttonY),
      anchor: Anchor.topLeft,
    )
      ..add(RectangleComponent(
        size: Vector2(200, 48),
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
          position: Vector2(100, 24),
        ),
      );
    add(battleButton);

    enemyPanel = EnemyDetailPanel();
    registerVerticalStackComponent('enemyPanel', enemyPanel, size.y * 0.45);

    GameLogger.debug(
        LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (battleButton.toRect().contains(event.localPosition.toOffset())) {
      GameLogger.debug(LogCategory.ui, 'Start Battle button pressed');
      // Just push the combat scene
      SceneManager().pushScene('outpost');
    }
    // Handle Back button
    if (backButton.toRect().contains(event.localPosition.toOffset())) {
      GameLogger.debug(LogCategory.ui, 'Back button pressed');
      SceneManager().moveScene('title');
    }
  }
}
