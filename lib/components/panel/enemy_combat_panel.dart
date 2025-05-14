import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flame/game.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:flutter/painting.dart';
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