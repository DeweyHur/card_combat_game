import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/mage.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/components/layout/player_selection_box.dart';

class PlayerSelectionPanel extends BasePanel with TapCallbacks {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];
  final List<PlayerSelectionBox> characterBoxes = [];
  Function(PlayerBase)? onPlayerSelected;

  PlayerSelectionPanel();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionPanel loading...');

    // Set size and position
    size = Vector2(800, 600);

    // Create character selection boxes
    final boxWidth = size.x * 0.15;
    final boxHeight = size.y * 0.15;
    final spacing = size.x * 0.03;
    final startX = (size.x - (boxWidth * 3 + spacing * 2)) / 2;
    final startY = size.y * 0.3;

    for (int i = 0; i < 6; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final box = PlayerSelectionBox(
        position: Vector2(
          startX + (col * (boxWidth + spacing)),
          startY + (row * (boxHeight + spacing)),
        ),
        size: Vector2(boxWidth, boxHeight),
        index: i,
      );
      characterBoxes.add(box);
      add(box);
    }

    GameLogger.debug(LogCategory.ui, 'PlayerSelectionPanel loaded successfully');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final position = event.canvasPosition;
    
    // Check for character selection
    final player = getPlayerAtPosition(position);
    if (player != null) {
      selectPlayer(player);
      onPlayerSelected?.call(player);
    }
  }

  @override
  void updateUI() {
    // Update any UI elements if needed
  }

  void selectPlayer(PlayerBase player) {
    // Update selection state of boxes
    for (var box in characterBoxes) {
      box.isSelected = box.getPlayer() == player;
    }
  }

  PlayerBase? getSelectedPlayer() {
    for (var box in characterBoxes) {
      if (box.isSelected) {
        return box.getPlayer();
      }
    }
    return null;
  }

  PlayerBase? getPlayerAtPosition(Vector2 position) {
    for (var box in characterBoxes) {
      if (box.containsPoint(position)) {
        return box.getPlayer();
      }
    }
    return null;
  }
} 