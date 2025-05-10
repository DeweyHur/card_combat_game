import 'package:flutter/material.dart';
import 'character_base.dart';

class EnemyAction {
  final String name;
  final String description;
  final int damage;
  final StatusEffect? statusEffect;
  final int? statusDuration;

  const EnemyAction({
    required this.name,
    required this.description,
    required this.damage,
    this.statusEffect,
    this.statusDuration,
  });
}

abstract class EnemyBase extends CharacterBase {
  final List<EnemyAction> possibleActions;
  EnemyAction? nextAction;

  EnemyBase({
    required super.name,
    required super.emoji,
    required super.maxHp,
    required super.color,
    required this.possibleActions,
  });

  void setNextAction() {
    if (possibleActions.isNotEmpty) {
      nextAction = possibleActions[DateTime.now().millisecondsSinceEpoch % possibleActions.length];
    }
  }

  void executeAction(CharacterBase target) {
    if (nextAction == null) return;

    // Apply damage
    target.takeDamage(nextAction!.damage);

    // Apply status effect if any
    if (nextAction!.statusEffect != null && nextAction!.statusDuration != null) {
      target.addStatusEffect(nextAction!.statusEffect!, nextAction!.statusDuration!);
    }

    // Set next action
    setNextAction();
  }

  @override
  void updateStatusEffects() {
    super.updateStatusEffects();
    // Enemies might have special status effect handling
  }
} 