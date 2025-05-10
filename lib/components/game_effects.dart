import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Card;
import '../card.dart';
import '../card_combat_game.dart';
import 'cards_panel.dart';
import 'damage_effect.dart';
import 'heal_effect.dart';
import 'dot_effect.dart';
import 'status_effect.dart';

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

  static RectangleComponent createCardEffect(CardType type, Vector2 position, Vector2 size) {
    final effectColor = _getEffectColor(type);
    final effect = RectangleComponent(
      size: size,
      position: position,
      paint: Paint()..color = effectColor.withValues(alpha: 0.5),
    );
    return effect;
  }

  static Component createDamageEffect(
    Vector2 position,
    int damage,
    bool isPlayer,
  ) {
    return DamageEffect.create(position, damage, isPlayer);
  }

  static Component createHealEffect(
    Vector2 position,
    int healAmount,
    bool isPlayer,
  ) {
    return HealEffect.create(position, healAmount, isPlayer);
  }

  static Component createDoTEffect(
    Vector2 position,
    int damage,
    StatusEffect effectType,
    bool isPlayer,
  ) {
    return DoTEffect.create(position, damage, effectType, isPlayer);
  }

  static Component createStatusEffect(
    Vector2 position,
    StatusEffect effectType,
    bool isPlayer,
  ) {
    return StatusEffectComponent.create(position, effectType, isPlayer);
  }

  static Component createCardVisual(
    Card cardData,
    int index,
    Vector2 cardAreaPosition,
    Vector2 cardAreaSize,
    Function(Card) onCardPlayed,
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