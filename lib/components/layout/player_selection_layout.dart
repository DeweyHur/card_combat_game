import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/player_run_detail_panel.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/player.dart';

class PlayerSelectionLayout extends PositionComponent
    with HasGameReference, TapCallbacks, VerticalStackMixin {
  late PlayerRunDetailPanel detailPanel;
  late PlayerSelectionPanel selectionPanel;
  late PositionComponent battleButton;
  late PositionComponent backButton;

  final List<PlayerRun> playerRuns;
  final Function(PlayerRun) onPlayerSelected;

  PlayerSelectionLayout({
    required this.playerRuns,
    required this.onPlayerSelected,
  }) : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = findGame()!.size;

    // Create detail panel
    detailPanel = PlayerRunDetailPanel();
    selectionPanel = PlayerSelectionPanel(
      playerRuns: playerRuns,
      onPlayerSelected: (playerRun) {
        detailPanel.updatePlayer(playerRun);
        onPlayerSelected(playerRun);
      },
    );

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
      size: Vector2(160, 48),
      position: Vector2(size.x - 180, buttonY),
      anchor: Anchor.topLeft,
    )
      ..add(RectangleComponent(
        size: Vector2(160, 48),
        paint: Paint()..color = Colors.green,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Start Battle',
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
    add(battleButton);

    GameLogger.debug(
        LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  @override
  void onTapDown(TapDownEvent event) {
    final pos = event.canvasPosition;
    if (backButton.toRect().contains(pos.toOffset())) {
      SceneManager().popScene();
    } else if (battleButton.toRect().contains(pos.toOffset())) {
      // Handle battle button tap
      GameLogger.debug(LogCategory.ui, 'Battle button tapped');
    }
  }
}
