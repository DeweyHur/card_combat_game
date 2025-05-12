import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';
import 'package:card_combat_app/models/game_card.dart';

class DoTEffect extends PositionComponent {
  final StatusEffect effect;
  final int value;
  final VoidCallback? onComplete;
  late FadingTextComponent _textComponent;
  static const double _fadeSpeed = 2.0;

  DoTEffect({
    required Vector2 position,
    required Vector2 size,
    required this.effect,
    required this.value,
    this.onComplete,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'DoT effect created: $effect for $value damage');
    
    _textComponent = FadingTextComponent(
      '-$value',
      Vector2(size.x / 2, size.y / 2),
      style: const TextStyle(
        color: Colors.purple,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_textComponent.isFinished) {
      onComplete?.call();
      removeFromParent();
      GameLogger.debug(LogCategory.game, 'DoT effect faded out and removed.');
    }
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'DoT effect faded out and removed.');
    super.onRemove();
  }
} 