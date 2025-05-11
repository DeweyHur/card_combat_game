import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/mage.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/components/layout/player_selection_box.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class PlayerSelectionLayout extends PositionComponent with HasGameRef {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  late final TextComponent titleText;
  final List<PlayerSelectionBox> characterBoxes = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionLayout loading...');

    // Set size from gameRef
    size = gameRef.size;

    // Add title
    titleText = TextComponent(
      text: 'Choose Your Character',
      position: Vector2(size.x / 2, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(titleText);

    // Create character selection boxes
    final boxWidth = size.x * 0.2;
    final boxHeight = size.y * 0.3;
    final spacing = size.x * 0.05;
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
    
    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  PlayerBase? getSelectedPlayer(Vector2 position) {
    for (var box in characterBoxes) {
      if (box.containsPoint(position)) {
        return box.getPlayer();
      }
    }
    return null;
  }
} 