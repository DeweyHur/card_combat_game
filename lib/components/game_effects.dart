import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../models/card.dart';

class GameEffects {
  static Color _getEffectColor(CardType type) {
    switch (type) {
      case CardType.attack:
        return Colors.red;
      case CardType.heal:
        return Colors.green;
      case CardType.statusEffect:
        return Colors.purple;
      case CardType.cure:
        return Colors.blue;
    }
  }

  static RectangleComponent createCardEffect(CardType type, Vector2 position, Vector2 size) {
    final effectColor = _getEffectColor(type);
    final effect = RectangleComponent(
      size: size,
      position: position,
      paint: Paint()..color = effectColor.withValues(alpha: 0.5),
    );

    // Add fade out effect
    effect.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
      ),
    );

    return effect;
  }

  static TextComponent createDamageEffect(
    Vector2 position,
    int damage,
    bool isPlayer,
  ) {
    final damageText = TextComponent(
      text: '-$damage',
      position: position,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );

    // Add floating animation
    damageText.add(
      SequenceEffect(
        [
          MoveEffect.by(
            Vector2(0, -50),
            EffectController(duration: 0.5, curve: Curves.easeOut),
          ),
          OpacityEffect.fadeOut(
            EffectController(duration: 0.3, curve: Curves.easeOut),
          ),
        ],
      ),
    );

    return damageText;
  }
} 