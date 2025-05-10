import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CardsPanel extends PositionComponent {
  late RectangleComponent background;
  late RectangleComponent border;
  late TextComponent cardAreaText;
  late TextComponent gameInfoText;
  late TextComponent turnText;

  // Card layout constants
  static const double cardWidth = 140.0;
  static const double cardHeight = 180.0;
  static const double cardSpacing = 0.0;
  static const double cardTopMargin = 60.0;
  static const int maxCards = 3;

  CardsPanel({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Create background (make it more visible)
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue.withOpacity(0.3),
    );
    add(background);

    // Create border (make it more visible)
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );
    add(border);

    // Create card area text
    cardAreaText = TextComponent(
      text: 'Cards',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 20),
    );
    add(cardAreaText);

    // Create game info text
    gameInfoText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(20, size.y - 40),
    );
    add(gameInfoText);

    // Create turn text
    turnText = TextComponent(
      text: 'Turn: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(size.x - 100, 20),
    );
    add(turnText);

    GameLogger.info(LogCategory.ui, 'CardsPanel loaded with size: ${size.x}x${size.y}');
  }

  void updateGameInfo(String info) {
    gameInfoText.text = info;
  }

  void updateTurn(int turn) {
    turnText.text = 'Turn: $turn';
  }

  Vector2 calculateCardPosition(int index) {
    final totalWidth = (maxCards * cardWidth) + ((maxCards - 1) * cardSpacing);
    final startX = (size.x - totalWidth) / 2;

    return Vector2(
      startX + (index * (cardWidth + cardSpacing)),
      cardTopMargin,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Debug rendering
    final debugPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw panel boundary
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      debugPaint,
    );
    
    // Draw card positions
    for (int i = 0; i < maxCards; i++) {
      final pos = calculateCardPosition(i);
      canvas.drawRect(
        Rect.fromLTWH(pos.x, pos.y, cardWidth, cardHeight),
        debugPaint..color = Colors.blue.withOpacity(0.3),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Remove the frequent logging
  }
} 