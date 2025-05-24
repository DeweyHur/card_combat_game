import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/events.dart';

class CreditScene extends BaseScene with TapCallbacks {
  CreditScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.purple, options: options);

  final List<String> credits = const [
    'Card Combat',
    'Developed by DewIn Studio',
    '2024',
    '',
    'Lead Developer: Dewey "The Cardmaster"',
    'Art Director: Pixel Pete',
    'Sound Wizard: Melody Maker',
    'QA Overlord: Bug Zapper',
    'Narrative Designer: Story Spinner',
    'AI Consultant: GPT-4',
    '',
    'Special Thanks:',
    '  - The Coffee Machine',
    '  - The Rubber Duck',
    '  - The Stack Overflow Community',
    '  - All Playtesters',
    '',
    'Fictional Contributors:',
    '  - Sir Shuffle, Keeper of Decks',
    '  - Lady Luck, RNG Specialist',
    '  - The Phantom Coder',
    '  - Captain Placeholder',
    '',
    'Inspirations:',
    '  - Classic Card Games',
    '  - 8-bit Adventures',
    '  - Saturday Morning Cartoons',
    '',
    'Made with Flutter & Flame',
    '',
    'No cards were harmed in the making of this game.',
    '',
    'Thank you for playing!',
  ];

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final size = this.size;

    // Scrollable area setup
    final double scrollAreaTop = size.y * 0.12;
    final double scrollAreaHeight = size.y * 0.7;
    final double scrollAreaBottom = scrollAreaTop + scrollAreaHeight;
    final double lineHeight = 36;
    final double totalHeight = credits.length * lineHeight;

    // Animate scroll
    final double time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final double scrollSpeed = 30.0; // pixels per second
    final double scrollOffset =
        (time * scrollSpeed) % (totalHeight + scrollAreaHeight);
    final double startY = scrollAreaBottom - scrollOffset;

    // Draw credits
    for (int i = 0; i < credits.length; i++) {
      final y = startY + i * lineHeight;
      if (y < scrollAreaTop - lineHeight || y > scrollAreaBottom + lineHeight)
        continue;
      final textPainter = TextPainter(
        text: TextSpan(
          text: credits[i],
          style: TextStyle(
            fontSize: i == 0 ? 32 : 22,
            fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.x * 0.9);
      textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2, y),
      );
    }

    // Draw a fade effect at top and bottom
    final fadeHeight = 40.0;
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.purple,
          Colors.purple.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, scrollAreaTop, size.x, fadeHeight));
    canvas.drawRect(
        Rect.fromLTWH(0, scrollAreaTop, size.x, fadeHeight), fadePaint);
    final fadePaintBottom = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.purple,
          Colors.purple.withOpacity(0.0),
        ],
      ).createShader(
          Rect.fromLTWH(0, scrollAreaBottom - fadeHeight, size.x, fadeHeight));
    canvas.drawRect(
        Rect.fromLTWH(0, scrollAreaBottom - fadeHeight, size.x, fadeHeight),
        fadePaintBottom);

    // Draw back button
    const buttonText = 'Back';
    final buttonPainter = TextPainter(
      text: const TextSpan(
        text: buttonText,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final buttonRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.92),
      width: buttonPainter.width + 40,
      height: 60,
    );
    final buttonPaint = Paint()..color = Colors.deepPurpleAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(buttonRect, const Radius.circular(12)),
      buttonPaint,
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
    final pos = Offset(event.canvasPosition.x, event.canvasPosition.y);
    final buttonPainter = TextPainter(
      text: const TextSpan(
        text: 'Back',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final buttonRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * 0.92),
      width: buttonPainter.width + 40,
      height: 60,
    );
    if (buttonRect.contains(pos)) {
      SceneManager().moveScene('title');
    }
  }
}
