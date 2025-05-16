import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/base_player_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/utils/color_utils.dart';

class PlayerCombatPanel extends BasePlayerPanel with AreaFillerMixin, ShakeMixin implements CombatWatcher {

  late CombatManager combatManager;
  bool _isLoaded = false;
  late TextComponent statusEffectText;

  PlayerCombatPanel({required super.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add status effect text below the health bar (after statsRow)
    statusEffectText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
    addToVerticalStack(statusEffectText, 24);
    _isLoaded = true;
  }

  void initialize(GameCharacter player, CombatManager combatManager) {
    this.combatManager = combatManager;
    if (_isLoaded) {
      updateUI();
    }
  }

  @override
  void updateUI() {
    super.updateUI();
    if (!_isLoaded) return;
    final player = combatManager.player;
    // Update status effect text for all effects
    if (player.statusEffects.isNotEmpty) {
      final effectStrings = player.statusEffects.entries.map((entry) {
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
  void render(Canvas canvas) {
    super.render(canvas);
    drawAreaFiller(
      canvas,
      colorFromString(player.color).withOpacity(0.3),
      borderColor: colorFromString(player.color),
      borderWidth: 2.0,
    );
  }

  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == player) {
      if (event.type == CombatEventType.damage) {
        final effect = GameEffects.createCardEffect(
          event.card.type,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          color: Colors.red,
          emoji: '💔',
          value: event.value,
        )..priority = 100;
        add(effect);
        shakeForType(event.card.type);
      } else if (event.type == CombatEventType.heal || event.type == CombatEventType.status) {
        final effect = GameEffects.createCardEffect(
          event.card.type,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          value: event.value,
        )..priority = 100;
        add(effect);
        shakeForType(event.card.type);
      } else if (event.type == CombatEventType.cure) {
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