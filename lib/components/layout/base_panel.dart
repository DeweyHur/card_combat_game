import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class BasePanel extends PositionComponent {
  late RectangleComponent background;
  late RectangleComponent border;
  late TextComponent character;
  late TextComponent hpText;
  late TextComponent statusText;
  
  final Vector2 gameSize;
  final String characterEmoji;
  final Color hpColor;
  final bool isTop;

  BasePanel({
    required this.gameSize,
    required this.characterEmoji,
    required this.hpColor,
    required this.isTop,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set panel position and size
    position = Vector2(0, isTop ? 0 : gameSize.y * 0.7);
    size = Vector2(gameSize.x, gameSize.y * 0.3);

    GameLogger.info(LogCategory.ui, '${isTop ? "Enemy" : "Player"} Panel:');
    GameLogger.info(LogCategory.ui, '  Position: (${position.x}, ${position.y})');
    GameLogger.info(LogCategory.ui, '  Size: ${size.x} x ${size.y}');
    GameLogger.info(LogCategory.ui, '  Game Size: ${gameSize.x} x ${gameSize.y}');

    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    add(background);

    // Create border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(border);

    // Create character
    character = TextComponent(
      text: characterEmoji,
      position: Vector2(size.x * 0.15, size.y * 0.4),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 100,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 3,
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(-2, -2),
              blurRadius: 3,
              color: Colors.black,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(character);

    // Create HP text
    hpText = TextComponent(
      text: 'HP: 0/0',
      position: Vector2(size.x * 0.4, size.y * 0.3),
      textRenderer: TextPaint(
        style: TextStyle(
          color: hpColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            const Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black,
            ),
          ],
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(hpText);

    // Create status text
    statusText = TextComponent(
      text: 'No Status Effects',
      position: Vector2(size.x * 0.4, size.y * 0.5),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(statusText);
  }

  void updateHp(int currentHp, int maxHp) {
    hpText.text = 'HP: $currentHp/$maxHp';
  }

  void updateStatus(String status) {
    statusText.text = status;
  }
} 