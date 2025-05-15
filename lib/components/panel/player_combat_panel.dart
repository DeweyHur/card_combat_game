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

  PlayerCombatPanel({required super.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
    updateDescription(player.description);
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
} 