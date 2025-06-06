import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/effects/fading_text_component.dart';
import 'package:card_combat_app/models/game_character.dart';

class StatusEffectComponent extends PositionComponent {
  final StatusEffect effect;
  final VoidCallback? onComplete;
  late FadingTextComponent _textComponent;

  StatusEffectComponent({
    required Vector2 position,
    required Vector2 size,
    required this.effect,
    this.onComplete,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Status effect created: $effect');

    _textComponent = FadingTextComponent(
      _getEffectText(),
      Vector2(size.x / 2, size.y / 2),
      style: TextStyle(
        color: _getEffectColor(),
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
      GameLogger.debug(
          LogCategory.game, 'Status effect faded out and removed.');
    }
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
      default:
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
      default:
        return 'STATUS';
    }
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Status effect faded out and removed.');
    super.onRemove();
  }
}
