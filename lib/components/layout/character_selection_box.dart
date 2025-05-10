import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CharacterSelectionBox extends PositionComponent with TapCallbacks {
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final Vector2 _size;
  final Function() onSelected;

  late RectangleComponent box;
  late TextComponent emojiText;
  late TextComponent nameText;
  late TextComponent descriptionText;

  CharacterSelectionBox({
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    required Vector2 size,
    required this.onSelected,
    required Vector2 position,
  }) : _size = size,
       super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Loading CharacterSelectionBox for $name');

    // Create box
    box = RectangleComponent(
      size: _size,
      paint: Paint()..color = color,
    );
    add(box);

    // Add emoji
    emojiText = TextComponent(
      text: emoji,
      position: Vector2(50, _size.y * 0.35),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.center,
    );
    add(emojiText);

    // Add name
    nameText = TextComponent(
      text: name,
      position: Vector2(120, _size.y * 0.35),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(nameText);

    // Add description
    descriptionText = TextComponent(
      text: description,
      position: Vector2(50, _size.y * 0.75),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.topLeft,
    );
    add(descriptionText);

    GameLogger.debug(LogCategory.game, 'CharacterSelectionBox loaded for $name');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final tapPosition = event.canvasPosition;
    if (containsPoint(tapPosition)) {
      GameLogger.info(LogCategory.game, 'Character box tapped: $name');
      onSelected();
    }
  }

  bool containsPoint(Vector2 point) {
    final boxPosition = position;
    final boxSize = _size;
    
    return point.x >= boxPosition.x &&
           point.x <= boxPosition.x + boxSize.x &&
           point.y >= boxPosition.y &&
           point.y <= boxPosition.y + boxSize.y;
  }
} 