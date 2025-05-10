import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/components/effects/status_effect.dart';
import 'package:flutter/material.dart';

abstract class EnemyBase extends Character {
  final String emoji;
  final Color color;

  EnemyBase({
    required String name,
    required this.emoji,
    required int maxHp,
    required this.color,
  }) : super(name: name, maxHealth: maxHp);

  GameCard getNextAction();

  @override
  void executeAction(Character target) {
    final action = getNextAction();
    switch (action.type) {
      case CardType.attack:
        target.takeDamage(action.value);
        break;
      case CardType.heal:
        heal(action.value);
        break;
      case CardType.statusEffect:
        if (action.statusEffectToApply != null) {
          target.addStatusEffect(action.statusEffectToApply!, action.statusDuration);
        }
        break;
      case CardType.cure:
        removeAllStatusEffects();
        break;
    }
  }

  @override
  void updateStatusEffects() {
    super.updateStatusEffects();
  }
} 