import 'package:flutter/material.dart' as material;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/components/panel/card_upgrade_panel.dart';
import 'package:card_combat_app/components/panel/deck_view_panel.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class CampEventPanel extends PositionComponent with TapCallbacks {
  final Player player;
  final List<Card> playerCards;
  bool hasRested = false;
  bool hasUpgraded = false;
  bool hasRemovedCard = false;

  CampEventPanel({
    required this.player,
    required this.playerCards,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2(800, 600));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Title
    add(TextComponent(
      text: 'Camp Site',
      position: Vector2(size.x * 0.125, size.y * 0.083),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 32,
          color: material.Colors.black,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    ));

    // Description
    add(TextComponent(
      text: 'You\'ve found a safe place to rest. What would you like to do?',
      position: Vector2(size.x * 0.125, size.y * 0.167),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 18,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Current Health
    add(TextComponent(
      text: 'Current Health: ${player.currentHealth}/${player.maxHealth}',
      position: Vector2(size.x * 0.125, size.y * 0.233),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 16,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Rest Button
    add(SimpleButtonComponent.text(
      text: 'Rest (Recover 30% Health)',
      size: Vector2(size.x * 0.375, size.y * 0.083),
      color: material.Colors.green,
      onPressed: () {
        if (!hasRested) {
          final healAmount = (player.maxHealth * 0.3).round();
          player.currentHealth =
              (player.currentHealth + healAmount).clamp(0, player.maxHealth);
          hasRested = true;
          _updateHealthText();
        }
      },
      position: Vector2(size.x * 0.125, size.y * 0.333),
    ));

    // Upgrade Button
    add(SimpleButtonComponent.text(
      text: 'Upgrade a Card',
      size: Vector2(size.x * 0.375, size.y * 0.083),
      color: material.Colors.blue,
      onPressed: () {
        if (!hasUpgraded && playerCards.isNotEmpty) {
          final card = playerCards.first;
          final gameCard = GameCard(
            name: card.name,
            description: card.description,
            type: CardType.attack, // Default to attack type
            value: 10, // Default value
            cost: 1, // Default cost
          );
          late final CardUpgradePanel panel;
          panel = CardUpgradePanel(
            card: gameCard,
            onUpgrade: (upgradedCard) {
              hasUpgraded = true;
              panel.removeFromParent();
            },
            onCancel: () {
              panel.removeFromParent();
            },
            position: Vector2(size.x * 0.125, size.y * 0.467),
            size: Vector2(size.x * 0.75, size.y * 0.667),
          );
          add(panel);
        }
      },
      position: Vector2(size.x * 0.125, size.y * 0.467),
    ));

    // View/Remove Cards Button
    add(SimpleButtonComponent.text(
      text: 'View/Remove Cards',
      size: Vector2(size.x * 0.375, size.y * 0.083),
      color: material.Colors.orange,
      onPressed: () {
        if (!hasRemovedCard && playerCards.length > 1) {
          final gameCards = playerCards
              .map((card) => GameCard(
                    name: card.name,
                    description: card.description,
                    type: CardType.attack, // Default to attack type
                    value: 10, // Default value
                    cost: 1, // Default cost
                  ))
              .toList();
          late final DeckViewPanel panel;
          panel = DeckViewPanel(
            cards: gameCards,
            onCardRemoved: (removedCard) {
              final cardToRemove = playerCards.firstWhere(
                (card) => card.name == removedCard.name,
                orElse: () => playerCards.first,
              );
              player.deck.removeCard(cardToRemove);
              playerCards.remove(cardToRemove);
              hasRemovedCard = true;
              panel.removeFromParent();
            },
            onClose: () {
              panel.removeFromParent();
            },
            position: Vector2(size.x * 0.125, size.y * 0.6),
            size: Vector2(size.x * 0.75, size.y * 0.667),
          );
          add(panel);
        }
      },
      position: Vector2(size.x * 0.125, size.y * 0.6),
    ));

    // Continue Button
    add(SimpleButtonComponent.text(
      text: 'Continue',
      size: Vector2(size.x * 0.375, size.y * 0.083),
      color: material.Colors.purple,
      onPressed: () => SceneManager().popScene(),
      position: Vector2(size.x * 0.125, size.y * 0.733),
    ));
  }

  void _updateHealthText() {
    // Find and update the health text component
    children.whereType<TextComponent>().forEach((component) {
      if (component.text.startsWith('Current Health:')) {
        component.text =
            'Current Health: ${player.currentHealth}/${player.maxHealth}';
      }
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Convert the tap position to local coordinates
    final localPosition = event.canvasPosition - position;

    // Check if any button was tapped
    for (final component in children) {
      if (component is SimpleButtonComponent) {
        final buttonRect = Rect.fromLTWH(
          component.position.x,
          component.position.y,
          component.size.x,
          component.size.y,
        );
        if (buttonRect.contains(localPosition.toOffset())) {
          component.onPressed?.call();
          break;
        }
      }
    }
  }
}
