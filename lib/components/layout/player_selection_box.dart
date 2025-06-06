import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class PlayerSelectionBox extends PositionComponent with TapCallbacks {
  final PlayerRun playerRun;
  final Function(PlayerRun) onSelected;
  bool isSelected = false;
  bool isHovered = false;

  late RectangleComponent background;
  late TextComponent nameText;
  late TextComponent emojiText;

  PlayerSelectionBox({
    required Vector2 position,
    required Vector2 size,
    required this.playerRun,
    required this.onSelected,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = isSelected ? Colors.blue : Colors.grey,
    );
    add(background);

    // Create border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withAlpha(77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    add(border);

    // Create text components
    nameText = TextComponent(
      text: playerRun.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    emojiText = TextComponent(
      text: playerRun.emoji,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(emojiText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    GameLogger.debug(
        LogCategory.ui, 'PlayerSelectionBox tapped: ${playerRun.name}');
    onSelected(playerRun);
  }

  void updateAppearance() {
    background.paint = Paint()
      ..color =
          isSelected ? Colors.blue.withAlpha(77) : Colors.grey.withAlpha(77);
  }

  void onHoverEnter() {
    isHovered = true;
    if (!isSelected) {
      background.paint.color = Colors.grey.withAlpha(128);
    }
  }

  void onHoverExit() {
    isHovered = false;
    if (!isSelected) {
      background.paint.color = Colors.grey.withAlpha(77);
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }

  @override
  void render(Canvas canvas) {
    // Draw box background
    final paint = Paint()
      ..color =
          isSelected ? Colors.blue.withAlpha(77) : Colors.grey.withAlpha(77)
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    nameText.render(
      canvas,
      playerRun.name,
      Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );

    // Draw emoji
    final emojiText = TextPaint(
      style: const TextStyle(
        fontSize: 32,
      ),
    );
    emojiText.render(
      canvas,
      playerRun.emoji,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
