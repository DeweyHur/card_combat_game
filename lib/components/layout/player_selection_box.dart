import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/player/player_base.dart';

class PlayerSelectionBox extends PositionComponent with TapCallbacks {
  final PlayerBase character;
  final Function()? onSelected;
  bool isSelected = false;
  bool isHovered = false;

  late RectangleComponent box;
  late TextComponent nameText;
  late TextComponent statsText;

  PlayerSelectionBox({
    required this.character,
    required Vector2 position,
    required Vector2 size,
    this.onSelected,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Loading PlayerSelectionBox for ${character.name}');

    // Create box
    box = RectangleComponent(
      size: size,
      paint: Paint()..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
      anchor: Anchor.topLeft,
    );
    add(box);

    // Add name
    nameText = TextComponent(
      text: character.name,
      position: Vector2(20, size.y / 2 - 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(nameText);

    // Add stats
    statsText = TextComponent(
      text: 'HP: ${character.maxHealth} | ATK: ${character.attack} | DEF: ${character.defense}',
      position: Vector2(20, size.y / 2 + 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(statsText);

    GameLogger.debug(LogCategory.game, 'PlayerSelectionBox loaded for ${character.name}');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final tapPosition = event.canvasPosition;
    if (containsPoint(tapPosition)) {
      GameLogger.info(LogCategory.game, 'Player box tapped: ${character.name}');
      isSelected = !isSelected;
      box.paint = Paint()..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3);
      if (isSelected && onSelected != null) {
        onSelected!();
      }
    }
  }

  @override
  void onHoverEnter() {
    isHovered = true;
    box.paint.color = Colors.grey.withOpacity(0.5);
  }

  @override
  void onHoverExit() {
    isHovered = false;
    box.paint.color = Colors.grey.withOpacity(0.3);
  }

  bool containsPoint(Vector2 point) {
    final boxPosition = position;
    final boxSize = size;
    
    return point.x >= boxPosition.x &&
           point.x <= boxPosition.x + boxSize.x &&
           point.y >= boxPosition.y &&
           point.y <= boxPosition.y + boxSize.y;
  }

  @override
  void render(Canvas canvas) {
    // Draw box background
    final paint = Paint()
      ..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );

    // Draw character name
    final nameText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    nameText.render(
      canvas,
      character.name,
      Vector2(20, size.y / 2 - 20),
      anchor: Anchor.centerLeft,
    );

    // Draw stats
    final statsText = TextPaint(
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    );

    final stats = [
      'HP: ${character.maxHealth}',
      'Attack: ${character.attack}',
      'Defense: ${character.defense}',
    ];

    for (var i = 0; i < stats.length; i++) {
      statsText.render(
        canvas,
        stats[i],
        Vector2(20, size.y / 2 + 20 + i * 30),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
} 