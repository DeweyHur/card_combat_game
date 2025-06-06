import 'package:card_combat_app/models/enemy.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/name_emoji_interface.dart';

class ActionWithEmojiComponent extends Component {
  final EnemyRun enemy;
  final GameCard action;
  late TextComponent textComponent;

  ActionWithEmojiComponent({
    required this.enemy,
    required this.action,
  });

  static String format(EnemyRun enemy, GameCard action) {
    final buffer = StringBuffer();
    // Enemy emoji
    buffer.write('${(enemy as NameEmojiInterface).emoji} ');
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
      case CardType.shield:
        buffer.write('🛡️');
        break;
      case CardType.shieldAttack:
        buffer.write('🔰');
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
    if (action.type == CardType.statusEffect &&
        action.statusEffectToApply != null) {
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
        default:
          break;
      }
      if (action.statusDuration != null) {
        buffer.write(' x${action.statusDuration}');
      }
    }
    return buffer.toString();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    textComponent = TextComponent(
      text: format(enemy, action),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    add(textComponent);
  }
}
