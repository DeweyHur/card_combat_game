import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'base_scene.dart';
import 'package:flame/events.dart';

class GameResultScene extends BaseScene with TapCallbacks {
  String result = '';

  GameResultScene() : super(sceneBackgroundColor: Colors.black);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    result = DataController.instance.get<String>('gameResult') ?? '';
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final size = this.size;
    final textPainter = TextPainter(
      text: TextSpan(
        text: result == 'Victory' ? 'You Win!' : 'Defeat',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: result == 'Victory' ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, size.y * 0.4),
    );

    final buttonText = 'Return to Main Menu';
    final buttonPainter = TextPainter(
      text: TextSpan(
        text: buttonText,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final buttonRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.6),
      width: buttonPainter.width + 40,
      height: 60,
    );
    final paint = Paint()..color = Colors.blueAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(buttonRect, Radius.circular(12)),
      paint,
    );
    buttonPainter.paint(
      canvas,
      Offset(
        buttonRect.left + (buttonRect.width - buttonPainter.width) / 2,
        buttonRect.top + (buttonRect.height - buttonPainter.height) / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final size = this.size;
    final buttonText = 'Return to Main Menu';
    final buttonPainter = TextPainter(
      text: TextSpan(
        text: buttonText,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final buttonRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.6),
      width: buttonPainter.width + 40,
      height: 60,
    );
    if (buttonRect.contains(Offset(event.canvasPosition.x, event.canvasPosition.y))) {
      SceneManager().pushScene('title');
    }
  }
} 