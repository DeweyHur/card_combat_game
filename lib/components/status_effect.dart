import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'fading_text_component.dart';
import '../card.dart';

class StatusEffectComponent extends FadingTextComponent {
  final StatusEffect effectType;

  StatusEffectComponent({
    required Vector2 position,
    required this.effectType,
  }) : super(
          _getEffectText(effectType),
          position,
          style: const TextStyle(
            color: Colors.purple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ) {
    opacity = 1.0;
    _addFadeOutEffect();
  }

  static String _getEffectText(StatusEffect effect) {
    switch (effect) {
      case StatusEffect.poison:
        return '☠️ Poisoned!';
      case StatusEffect.burn:
        return '🔥 Burning!';
      case StatusEffect.freeze:
        return '❄️ Frozen!';
      case StatusEffect.none:
        return '💫';
    }
  }

  factory StatusEffectComponent.create(
    Vector2 position,
    StatusEffect effectType,
    bool isPlayer,
  ) {
    return StatusEffectComponent(
      position: position,
      effectType: effectType,
    );
  }

  void _addFadeOutEffect() {
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.8),
        onComplete: () {
          removeFromParent();
          print("Status effect faded out and removed.");
        },
      ),
    );
  }
} 