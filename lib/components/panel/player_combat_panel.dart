import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/utils/color_utils.dart';
import 'package:card_combat_app/models/game_card.dart';

class PlayerCombatPanel extends BasePanel
    with AreaFillerMixin, ShakeMixin
    implements CombatWatcher {
  late CombatManager combatManager;
  bool _isLoaded = false;
  late TextComponent statusEffectText;
  final PlayerRun playerRun;

  PlayerCombatPanel({required this.playerRun});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add status effect text below the health bar
    statusEffectText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
            color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
    registerVerticalStackComponent('statusEffectText', statusEffectText, 24);
    _isLoaded = true;
  }

  void initialize(CombatManager combatManager) {
    this.combatManager = combatManager;
    if (_isLoaded) {
      updateUI();
    }
  }

  @override
  void updateUI() {
    if (!_isLoaded) return;
    // Update status effect text for all effects
    if (playerRun.statusEffects.isNotEmpty) {
      final effectStrings = playerRun.statusEffects.entries.map((entry) {
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
      statusEffectText.text = 'No Status Effect';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawAreaFiller(
      canvas,
      colorFromString(playerRun.color).withAlpha(77),
      borderColor: colorFromString(playerRun.color),
      borderWidth: 2.0,
    );
  }

  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == playerRun) {
      if (event.type == CombatEventType.damage) {
        final effect = GameEffects.createCardEffect(
          event.card?.type ?? CardType.attack,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          color: Colors.red,
          emoji: '💔',
          value: event.value ?? 0,
        )..priority = 100;
        add(effect);
        if (event.card?.type != null) {
          shakeForType(event.card!.type);
        }
      } else if (event.type == CombatEventType.heal ||
          event.type == CombatEventType.status) {
        final effect = GameEffects.createCardEffect(
          event.card?.type ?? CardType.attack,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          value: event.value ?? 0,
        )..priority = 100;
        add(effect);
        if (event.card?.type != null) {
          shakeForType(event.card!.type);
        }
      } else if (event.type == CombatEventType.status) {
        updateUI();
      }
    }
  }

  void showDotEffect(StatusEffect effect, int value) {
    final dot = GameEffects.createDoTEffect(
      Vector2(size.x / 2 - 50, size.y / 2 - 50),
      effect,
      value,
      onComplete: () {},
    )..priority = 200;
    add(dot);
  }
}
