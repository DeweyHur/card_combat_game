import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/panel/base_enemy_panel.dart';

class EnemyCombatPanel extends BaseEnemyPanel {
  TextComponent? actionText;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final initialAction = ActionWithEmojiComponent.format(
      enemy,
      enemy.getNextAction(),
    );
    actionText = TextComponent(
      text: 'Next Action: $initialAction',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    addToVerticalStack(actionText!, 20);
  }
  void updateAction(String action) {
    if (isLoaded && actionText != null) {
      actionText!.text = 'Next Action: $action';
    }
  }
  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == enemy) {
      if (event.type == CombatEventType.damage || event.type == CombatEventType.heal || event.type == CombatEventType.status) {
        showEffectForCard(event.card ?? event, () {
          updateHealth();
        });
        shakeForType(event.card?.type ?? CardType.attack);
      } else if (event.type == CombatEventType.cure) {
        updateHealth();
      }
    }
  }
} 