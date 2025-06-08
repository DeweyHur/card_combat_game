import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/models/enemy.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;

class ActionWithEmojiComponent extends PositionComponent {
  final EnemyRun enemy;
  final CardRun action;
  late TextComponent textComponent;

  ActionWithEmojiComponent({
    required this.enemy,
    required this.action,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  static String format(EnemyRun enemy, CardRun action) {
    final emoji = _getEmojiForAction(action);
    final value = action.value;
    switch (action.type) {
      case CardType.attack:
        return '$emoji ${enemy.name} attacks for $value damage';
      case CardType.heal:
        return '$emoji ${enemy.name} heals for $value HP';
      case CardType.statusEffect:
        return '$emoji ${enemy.name} applies ${action.statusEffect} for ${action.statusDuration} turns';
      case CardType.cure:
        return '$emoji ${enemy.name} removes all status effects';
      case CardType.shield:
        return '$emoji ${enemy.name} gains $value shield';
      case CardType.shieldAttack:
        return '$emoji ${enemy.name} attacks for $value damage and gains shield';
    }
  }

  static String _getEmojiForAction(CardRun action) {
    if (action.type == CardType.attack || action.type == CardType.heal) {
      return '⚔️';
    }
    if (action.type == CardType.statusEffect &&
        action.statusEffect == 'poison') {
      return '☠️';
    }
    return '🎯';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    textComponent = TextComponent(
      text: format(enemy, action),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 16,
          color: material.Colors.white,
        ),
      ),
    );
    add(textComponent);
  }
}
