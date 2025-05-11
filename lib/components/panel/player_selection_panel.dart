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
import 'package:flame/game.dart';

class PlayerSelectionPanel extends BasePanel with TapCallbacks, HasGameRef {
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

    // Log panel dimensions and position
    GameLogger.info(LogCategory.ui, 'PlayerSelectionPanel dimensions:');
    GameLogger.info(LogCategory.ui, '  - Game size: ${gameRef.size.x}x${gameRef.size.y}');
    GameLogger.info(LogCategory.ui, '  - Panel size: ${size.x}x${size.y}');
    GameLogger.info(LogCategory.ui, '  - Panel position: ${position.x},${position.y}');
    GameLogger.info(LogCategory.ui, '  - Panel absolute position: ${absolutePosition.x},${absolutePosition.y}');

    // Create character selection boxes with relative sizing
    final boxWidth = size.x * 0.25;  // 25% of panel width
    final boxHeight = size.y * 0.25; // 25% of panel height
    final spacing = size.x * 0.04;   // 4% of panel width
    final startX = -size.x * 0.35;   // Start from left side
    final startY = -size.y * 0.3;    // Start from top

    // Log box dimensions and layout
    GameLogger.info(LogCategory.ui, 'Box layout:');
    GameLogger.info(LogCategory.ui, '  - Box size: ${boxWidth}x${boxHeight}');
    GameLogger.info(LogCategory.ui, '  - Spacing: $spacing');
    GameLogger.info(LogCategory.ui, '  - Start position: $startX,$startY');

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
      
      // Log each box's position
      GameLogger.info(LogCategory.ui, 'Box $i position: ${box.position.x},${box.position.y}');
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw panel background
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
      borderPaint,
    );

    // Draw title
    final titlePaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    titlePaint.render(
      canvas,
      'Select Your Character',
      Vector2(0, -size.y * 0.4),
    );
  }
} 