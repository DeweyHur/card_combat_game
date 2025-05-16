import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'base_scene.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/models/game_character.dart';

class GameResultScene extends BaseScene with TapCallbacks {
  String result = '';
  GameCharacter? nextEnemy;

  GameResultScene() : super(sceneBackgroundColor: Colors.black);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    result = DataController.instance.get<String>('gameResult') ?? '';
    if (result == 'Victory') {
      // Get the next enemy from DataController
      nextEnemy = DataController.instance.get<GameCharacter>('nextEnemy');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final size = this.size;
    
    // Render result text
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
      Offset((size.x - textPainter.width) / 2, size.y * 0.3),
    );

    if (result == 'Victory') {
      // Render card upgrade compensation text
      final compensationText = 'Card Upgrade Available!';
      final compensationPainter = TextPainter(
        text: TextSpan(
          text: compensationText,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      compensationPainter.paint(
        canvas,
        Offset((size.x - compensationPainter.width) / 2, size.y * 0.4),
      );

      // Render next enemy information if available
      if (nextEnemy != null) {
        final nextEnemyText = 'Next Enemy: ${nextEnemy!.name}';
        final nextEnemyPainter = TextPainter(
          text: TextSpan(
            text: nextEnemyText,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        nextEnemyPainter.paint(
          canvas,
          Offset((size.x - nextEnemyPainter.width) / 2, size.y * 0.5),
        );
      }
    }

    // Render buttons
    final buttonY = result == 'Victory' ? 0.7 : 0.6;
    
    // Continue button (only show for victory)
    if (result == 'Victory') {
      final continueText = 'Continue';
      final continuePainter = TextPainter(
        text: TextSpan(
          text: continueText,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final continueRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * buttonY),
        width: continuePainter.width + 40,
        height: 60,
      );
      final continuePaint = Paint()..color = Colors.greenAccent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(continueRect, const Radius.circular(12)),
        continuePaint,
      );
      continuePainter.paint(
        canvas,
        Offset(
          continueRect.left + (continueRect.width - continuePainter.width) / 2,
          continueRect.top + (continueRect.height - continuePainter.height) / 2,
        ),
      );
    }

    // Return to Main Menu button
    final menuText = 'Return to Main Menu';
    final menuPainter = TextPainter(
      text: TextSpan(
        text: menuText,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final menuRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * (buttonY + 0.15)),
      width: menuPainter.width + 40,
      height: 60,
    );
    final menuPaint = Paint()..color = Colors.blueAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(menuRect, const Radius.circular(12)),
      menuPaint,
    );
    menuPainter.paint(
      canvas,
      Offset(
        menuRect.left + (menuRect.width - menuPainter.width) / 2,
        menuRect.top + (menuRect.height - menuPainter.height) / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final size = this.size;
    final pos = Offset(event.canvasPosition.x, event.canvasPosition.y);
    final buttonY = result == 'Victory' ? 0.7 : 0.6;

    // Check Continue button (only for victory)
    if (result == 'Victory') {
      final continueText = 'Continue';
      final continuePainter = TextPainter(
        text: TextSpan(
          text: continueText,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final continueRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * buttonY),
        width: continuePainter.width + 40,
        height: 60,
      );
      if (continueRect.contains(pos)) {
        // TODO: Navigate to card upgrade scene
        SceneManager().pushScene('card_upgrade');
        return;
      }
    }

    // Check Return to Main Menu button
    final menuText = 'Return to Main Menu';
    final menuPainter = TextPainter(
      text: TextSpan(
        text: menuText,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final menuRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * (buttonY + 0.15)),
      width: menuPainter.width + 40,
      height: 60,
    );
    if (menuRect.contains(pos)) {
      SceneManager().pushScene('title');
    }
  }
} 