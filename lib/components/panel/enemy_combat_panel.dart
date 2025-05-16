import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/panel/base_enemy_panel.dart';
import 'package:card_combat_app/models/game_character.dart';

class EnemyCombatPanel extends BaseEnemyPanel {
  TextComponent? actionText;
  TextComponent statusEffectText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addToVerticalStack(statusEffectText, 24);
    
    // You may want to implement a getNextAction method for GameCharacter
    final action = enemy.deck.isNotEmpty ? enemy.deck.first : null;
    final initialAction = action != null ? ActionWithEmojiComponent.format(enemy, action) : '';
    actionText = TextComponent(
      text: 'Next Action: $initialAction\n${action?.description ?? ''}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    addToVerticalStack(actionText!, 20);
  }
  void updateActionWithDescription(String action, String description) {
    if (isLoaded && actionText != null) {
      actionText!.text = 'Next Action: $action\n$description';
    }
  }
  void updateAction(String action) {
    // Deprecated: use updateActionWithDescription instead for description support
    if (isLoaded && actionText != null) {
      actionText!.text = 'Next Action: $action';
    }
  }
  @override
  void updateUI() {
    super.updateUI();
    // Update status effect text for all effects
    if (enemy.statusEffects.isNotEmpty) {
      final effectStrings = enemy.statusEffects.entries.map((entry) {
        final effect = entry.key;
        final duration = entry.value;
        String emoji;
        switch (effect) {
          case StatusEffect.poison:
            emoji = '☠️';
            break;
          case StatusEffect.burn:
            emoji = '🔥';
            break;
          case StatusEffect.freeze:
            emoji = '❄️';
            break;
          case StatusEffect.none:
          default:
            emoji = '';
            break;
        }
        return '$emoji ${effect.toString().split('.').last.toUpperCase()} x$duration';
      }).join('   ');
      statusEffectText.text = effectStrings;
    } else {
      statusEffectText.text = 'No Status Effect';
    }
  }
  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == enemy) {
      if (event.type == CombatEventType.damage || event.type == CombatEventType.heal || event.type == CombatEventType.status) {
        showEffectForCard(event.card, () {
          updateHealth();
        });
        shakeForType(event.card.type);
      } else if (event.type == CombatEventType.cure) {
        updateHealth();
      }
    }
  }
} 