import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/components/effects/damage_effect.dart';
import 'package:card_combat_app/components/effects/heal_effect.dart';
import 'package:card_combat_app/components/effects/status_effect.dart';
import 'package:card_combat_app/components/effects/dot_effect.dart';
import 'package:card_combat_app/components/layout/card_visual_component.dart';
import 'package:flutter/material.dart' hide Card;

class GameEffects {
  static Color _getEffectColor(CardType type) {
    switch (type) {
      case CardType.attack:
        return Colors.red;
      case CardType.heal:
        return Colors.green;
      case CardType.statusEffect:
        return Colors.purple;
      case CardType.cure:
        return Colors.blue;
    }
  }

  static Component createCardEffect(CardType type, Vector2 position, Vector2 size) {
    switch (type) {
      case CardType.attack:
        return DamageEffect(
          position: position,
          size: size,
          value: 5, // Default damage value
          isPlayer: false,
        );
      case CardType.heal:
        return HealEffect(
          position: position,
          size: size,
          value: 5, // Default heal value
        );
      case CardType.statusEffect:
        return StatusEffectComponent(
          position: position,
          size: size,
          effect: StatusEffect.poison, // Default status effect
        );
      case CardType.cure:
        return HealEffect(
          position: position,
          size: size,
          value: 5, // Default heal value
        );
    }
  }

  static Component createDamageEffect(Vector2 position, int value, bool isPlayer) {
    return DamageEffect(
      position: position,
      size: Vector2(100, 100),
      value: value,
      isPlayer: isPlayer,
    );
  }

  static Component createHealEffect(Vector2 position, int value) {
    return HealEffect(
      position: position,
      size: Vector2(100, 100),
      value: value,
    );
  }

  static Component createDoTEffect(Vector2 position, StatusEffect effect, int value) {
    return DoTEffect(
      position: position,
      size: Vector2(100, 100),
      effect: effect,
      value: value,
    );
  }

  static Component createStatusEffect(Vector2 position, StatusEffect effectType, bool isPlayer) {
    return StatusEffectComponent(
      position: position,
      size: Vector2(100, 100),
      effect: effectType,
    );
  }

  static Component createCardVisual(
    GameCard cardData,
    int index,
    Vector2 cardAreaPosition,
    Vector2 cardAreaSize,
    Function(GameCard) onCardPlayed,
    bool isPlayerTurn,
  ) {
    final totalWidth = (CardsPanel.maxCards * CardsPanel.cardWidth) + 
        ((CardsPanel.maxCards - 1) * CardsPanel.cardSpacing);
    final startX = cardAreaPosition.x + (cardAreaSize.x - totalWidth) / 2;

    final position = Vector2(
      startX + (index * (CardsPanel.cardWidth + CardsPanel.cardSpacing)),
      cardAreaPosition.y + CardsPanel.cardTopMargin,
    );

    return CardVisualComponent(
      cardData,
      position: position,
      size: Vector2(CardsPanel.cardWidth, CardsPanel.cardHeight),
      onCardPlayed: onCardPlayed,
      enabled: isPlayerTurn,
    );
  }
} 