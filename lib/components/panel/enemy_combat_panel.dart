import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/models/enemy.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:flutter/foundation.dart';

class EnemyCombatPanel extends BasePanel
    with ShakeMixin
    implements CombatWatcher {
  late final CombatManager combatManager;
  late final EnemyRun enemy;

  TextComponent? actionText;
  TextComponent statusEffectText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 16,
      ),
    ),
  );

  EnemyCombatPanel({required this.enemy});

  void initialize(CombatManager combatManager) {
    this.combatManager = combatManager;
    updateUI();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize with empty action text
    actionText = TextComponent(
      text: 'Next Action: Waiting...',
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 16,
        ),
      ),
    );
    registerVerticalStackComponent('actionText', actionText!, 20);
    registerVerticalStackComponent('statusEffectText', statusEffectText, 24);

    // Add name and emoji
    final nameEmojiText = TextComponent(
      text: '${enemy.emoji} ${enemy.name}',
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 24,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    );
    registerVerticalStackComponent('nameEmoji', nameEmojiText, 30);

    // Add health text
    final healthText = TextComponent(
      text: 'HP: ${enemy.currentHealth}/${enemy.maxHealth}',
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 20,
        ),
      ),
    );
    registerVerticalStackComponent('health', healthText, 30);

    GameLogger.debug(
        LogCategory.ui, 'EnemyCombatPanel loaded for ${enemy.name}');
  }

  void updateActionWithDescription(String action, String description) {
    if (actionText != null) {
      actionText!.text = 'Next Action: $action\n$description';
    }
  }

  @override
  void updateUI() {
    // Update health text
    final healthText = children.whereType<TextComponent>().firstWhere(
          (component) => component.text.startsWith('HP:'),
          orElse: () => TextComponent(text: ''),
        );
    healthText.text = 'HP: ${enemy.currentHealth}/${enemy.maxHealth}';

    // Update status effect text
    if (enemy.statusEffects.isNotEmpty) {
      final effectStrings = enemy.statusEffects.entries.map((entry) {
        final effect = entry.key;
        final duration = entry.value;
        String emoji = '';
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
            emoji = '';
            break;
          case StatusEffect.stun:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.vulnerable:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.weak:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.strength:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.dexterity:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.regeneration:
            // TODO: Handle this case.
            throw UnimplementedError();
          case StatusEffect.shield:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
        return '$emoji ${effect.toString().split('.').last.toUpperCase()} x$duration';
      }).join('   ');
      statusEffectText.text = effectStrings;
    } else {
      statusEffectText.text = '';
    }
  }

  void onCombatEvent(CombatEvent event) {
    if (event.target == enemy) {
      if (event.type == CombatEventType.damage ||
          event.type == CombatEventType.heal ||
          event.type == CombatEventType.status) {
        showEffectForCard(event.card, () {
          updateUI();
        });
        if (event.card?.type != null) {
          shakeForType(event.card!.type);
        }
      } else if (event.type == CombatEventType.heal) {
        updateUI();
      }
    }
  }

  void showEffectForCard(dynamic card, VoidCallback onComplete) {
    final effect = GameEffects.createCardEffect(
      card.type,
      Vector2(size.x / 2 - 50, size.y / 2 - 50),
      Vector2(100, 100),
      onComplete: onComplete,
    )..priority = 100;
    add(effect);
  }
}
