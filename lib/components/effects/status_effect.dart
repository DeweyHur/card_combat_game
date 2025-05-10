import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';
import 'package:card_combat_app/models/game_card.dart';

class StatusEffectComponent extends PositionComponent {
  final StatusEffect effect;
  double _opacity = 1.0;
  static const double _fadeSpeed = 2.0;

  StatusEffectComponent({
    required Vector2 position,
    required Vector2 size,
    required this.effect,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Status effect created: $effect');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _opacity -= dt * _fadeSpeed;
    if (_opacity <= 0) {
      removeFromParent();
      GameLogger.debug(LogCategory.game, 'Status effect faded out and removed.');
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getEffectColor().withOpacity(_opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: _getEffectText(),
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

  Color _getEffectColor() {
    switch (effect) {
      case StatusEffect.poison:
        return Colors.purple;
      case StatusEffect.burn:
        return Colors.orange;
      case StatusEffect.freeze:
        return Colors.blue;
      case StatusEffect.none:
        return Colors.grey;
    }
  }

  String _getEffectText() {
    switch (effect) {
      case StatusEffect.poison:
        return 'POISON';
      case StatusEffect.burn:
        return 'BURN';
      case StatusEffect.freeze:
        return 'FREEZE';
      case StatusEffect.none:
        return 'NONE';
    }
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Status effect faded out and removed.');
    super.onRemove();
  }
} 