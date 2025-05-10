import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';

class HealEffect extends PositionComponent {
  final int value;
  double _opacity = 1.0;
  static const double _fadeSpeed = 2.0;

  HealEffect({
    required Vector2 position,
    required Vector2 size,
    required this.value,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Heal effect created: $value HP');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _opacity -= dt * _fadeSpeed;
    if (_opacity <= 0) {
      removeFromParent();
      GameLogger.debug(LogCategory.game, 'Heal effect faded out and removed.');
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(_opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '+$value',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Heal effect faded out and removed.');
    super.onRemove();
  }
} 