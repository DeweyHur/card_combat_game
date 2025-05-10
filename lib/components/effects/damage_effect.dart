import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';

class DamageEffect extends PositionComponent {
  final int value;
  final bool isPlayer;
  late FadingTextComponent _textComponent;
  static const double _fadeSpeed = 2.0;

  DamageEffect({
    required Vector2 position,
    required Vector2 size,
    required this.value,
    this.isPlayer = false,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Damage effect created: $value damage');
    
    _textComponent = FadingTextComponent(
      '-$value',
      Vector2(size.x / 2, size.y / 2),
      style: const TextStyle(
        color: Colors.white,
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
      removeFromParent();
      GameLogger.debug(LogCategory.game, 'Damage effect faded out and removed.');
    }
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Damage effect faded out and removed.');
    super.onRemove();
  }
} 