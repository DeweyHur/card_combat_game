import 'package:flame/components.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/effects/damage_effect.dart';
import 'package:card_combat_app/components/effects/heal_effect.dart';
import 'package:card_combat_app/components/effects/status_effect.dart';
import 'package:card_combat_app/components/effects/dot_effect.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:flutter/material.dart' hide Card;

class GameEffects {
  static Component createCardEffect(
      CardType type, Vector2 position, Vector2 size,
      {VoidCallback? onComplete, Color? color, String? emoji, int value = 5}) {
    switch (type) {
      case CardType.attack:
        return DamageEffect(
          position: position,
          size: size,
          value: value,
          isPlayer: false,
          onComplete: onComplete,
          color: color ?? Colors.red,
          emoji: emoji ?? '💥',
        );
      case CardType.heal:
        return HealEffect(
          position: position,
          size: size,
          value: value,
          onComplete: onComplete,
        );
      case CardType.statusEffect:
        return StatusEffectComponent(
          position: position,
          size: size,
          effect: StatusEffect.poison, // Default status effect
          onComplete: onComplete,
        );
      case CardType.cure:
        return HealEffect(
          position: position,
          size: size,
          value: value,
          onComplete: onComplete,
        );
      case CardType.shield:
        return HealEffect(
          position: position,
          size: size,
          value: value,
          onComplete: onComplete,
        );
      case CardType.shieldAttack:
        return DamageEffect(
          position: position,
          size: size,
          value: value,
          isPlayer: false,
          onComplete: onComplete,
          color: color ?? Colors.orange,
          emoji: emoji ?? '🔰',
        );
    }
  }

  static Component createDamageEffect(
      Vector2 position, int value, bool isPlayer,
      {VoidCallback? onComplete, Color? color, String? emoji}) {
    return DamageEffect(
      position: position,
      size: Vector2(100, 100),
      value: value,
      isPlayer: isPlayer,
      onComplete: onComplete,
      color: color ?? Colors.red,
      emoji: emoji ?? '💥',
    );
  }

  static Component createHealEffect(Vector2 position, int value,
      {VoidCallback? onComplete}) {
    return HealEffect(
      position: position,
      size: Vector2(100, 100),
      value: value,
      onComplete: onComplete,
    );
  }

  static Component createDoTEffect(
      Vector2 position, StatusEffect effect, int value,
      {VoidCallback? onComplete}) {
    return DoTEffect(
      position: position,
      size: Vector2(100, 100),
      effect: effect,
      value: value,
      onComplete: onComplete,
    );
  }

  static Component createStatusEffect(
      Vector2 position, StatusEffect effectType, bool isPlayer,
      {VoidCallback? onComplete}) {
    return StatusEffectComponent(
      position: position,
      size: Vector2(100, 100),
      effect: effectType,
      onComplete: onComplete,
    );
  }

  static Component createCardVisual(
    CardRun cardData,
    int index,
    Vector2 cardAreaPosition,
    Vector2 cardAreaSize,
    Function(CardRun) onCardPlayed,
    bool isPlayerTurn,
  ) {
    const totalWidth = (CardVisualComponent.maxCards *
            CardVisualComponent.cardWidth) +
        ((CardVisualComponent.maxCards - 1) * CardVisualComponent.cardSpacing);
    final startX = cardAreaPosition.x + (cardAreaSize.x - totalWidth) / 2;

    final position = Vector2(
      startX +
          (index *
              (CardVisualComponent.cardWidth +
                  CardVisualComponent.cardSpacing)),
      cardAreaPosition.y + CardVisualComponent.cardTopMargin,
    );

    return CardVisualComponent(
      cardData,
      position: position,
      size: Vector2(
          CardVisualComponent.cardWidth, CardVisualComponent.cardHeight),
      onCardPlayed: onCardPlayed,
      enabled: isPlayerTurn,
    );
  }
}
