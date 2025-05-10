import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CardsPanel extends PositionComponent {
  late RectangleComponent background;
  late RectangleComponent border;
  late TextComponent cardAreaText;
  late TextComponent gameInfoText;
  late TextComponent turnText;

  CardsPanel({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    );
    add(background);

    // Create border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
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
  }

  void updateGameInfo(String info) {
    gameInfoText.text = info;
  }

  void updateTurn(int turn) {
    turnText.text = 'Turn: $turn';
  }
} 