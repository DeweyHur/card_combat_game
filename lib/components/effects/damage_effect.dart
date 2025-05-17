import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';

class DamageEffect extends PositionComponent {
  final int value;
  final bool isPlayer;
  final VoidCallback? onComplete;
  final Color color;
  final String emoji;
  late FadingTextComponent _textComponent;

  DamageEffect({
    required Vector2 position,
    required Vector2 size,
    required this.value,
    this.isPlayer = false,
    this.onComplete,
    this.color = Colors.red,
    this.emoji = '💥',
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Damage effect created: $value damage');

    _textComponent = FadingTextComponent(
      '$emoji -$value',
      Vector2(size.x / 2, size.y / 2),
      style: TextStyle(
        color: color,
        fontSize: 48,
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
      GameLogger.debug(
          LogCategory.game, 'Damage effect faded out and removed.');
    }
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Damage effect faded out and removed.');
    super.onRemove();
  }
}
