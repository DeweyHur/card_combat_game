import 'package:flutter/material.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';

class ActionWithEmojiComponent extends StatelessWidget {
  final EnemyBase enemy;
  final GameCard action;
  final TextStyle? style;

  const ActionWithEmojiComponent({
    Key? key,
    required this.enemy,
    required this.action,
    this.style,
  }) : super(key: key);

  static String format(EnemyBase enemy, GameCard action) {
    final buffer = StringBuffer();
    // Enemy emoji
    buffer.write('${enemy.emoji} ');
    // Action type emoji
    switch (action.type) {
      case CardType.attack:
        buffer.write('💥');
        break;
      case CardType.heal:
        buffer.write('💚');
        break;
      case CardType.statusEffect:
        buffer.write('🌀');
        break;
      case CardType.cure:
        buffer.write('✨');
        break;
    }
    buffer.write(' ');
    // Action name
    buffer.write(action.name);
    // Add value if relevant
    if (action.type == CardType.attack || action.type == CardType.heal) {
      buffer.write(' (${action.value})');
    }
    // Status effect emoji
    if (action.type == CardType.statusEffect && action.statusEffectToApply != null) {
      buffer.write(' ');
      switch (action.statusEffectToApply) {
        case StatusEffect.poison:
          buffer.write('☠️');
          break;
        case StatusEffect.burn:
          buffer.write('🔥');
          break;
        case StatusEffect.freeze:
          buffer.write('❄️');
          break;
        case StatusEffect.none:
        case null:
          break;
      }
      if (action.statusDuration != null) {
        buffer.write(' x${action.statusDuration}');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      format(enemy, action),
      style: style ?? const TextStyle(fontSize: 16),
    );
  }
} 