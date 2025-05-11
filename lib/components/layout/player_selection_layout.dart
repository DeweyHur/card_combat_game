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

class PlayerSelectionLayout extends PositionComponent {
  final Vector2 gameSize;
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  late final TextComponent titleText;
  late final List<PlayerSelectionBox> characterBoxes;

  PlayerSelectionLayout({
    required this.gameSize,
  }) : super(
    size: gameSize,
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add title
    titleText = TextComponent(
      text: 'Choose Your Character',
      position: Vector2(gameSize.x / 2, 50),
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
    characterBoxes = [];

    final boxWidth = gameSize.x * 0.8;
    final boxHeight = gameSize.y * 0.15;
    final spacing = gameSize.y * 0.015;
    final startX = (gameSize.x - boxWidth) / 2;
    final startY = gameSize.y * 0.2;

    for (var i = 0; i < availablePlayers.length; i++) {
      final y = startY + (i * (boxHeight + spacing));
      
      final box = PlayerSelectionBox(
        character: availablePlayers[i],
        position: Vector2(startX, y),
        size: Vector2(boxWidth, boxHeight),
      );
      
      add(box);
      characterBoxes.add(box);
    }
    
    GameLogger.debug(LogCategory.game, 'PlayerSelectionLayout loaded successfully');
  }

  PlayerBase? getSelectedPlayer(Vector2 position) {
    for (final box in characterBoxes) {
      if (box.containsPoint(position)) {
        return box.character;
      }
    }
    return null;
  }
} 