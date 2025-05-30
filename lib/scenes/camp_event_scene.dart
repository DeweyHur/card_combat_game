import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/components/panel/card_upgrade_panel.dart';
import 'package:card_combat_app/components/panel/deck_view_panel.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/card.dart';

class CampEventScene extends BaseScene {
  CampEventScene({Map<String, dynamic>? options})
      : super(
            sceneBackgroundColor: material.Colors.teal.shade100,
            options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CampEventPanel());
  }
}

class CampEventPanel extends PositionComponent {
  late final Player player;
  late final List<Card> playerCards;
  bool hasRested = false;
  bool hasUpgraded = false;
  bool hasRemovedCard = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize player from CSV
    player = await Player.loadFromCSV('Mage');
    playerCards = player.deck.cards;

    // Title
    add(TextComponent(
      text: 'Camp Site',
      position: Vector2(100, 50),
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
      position: Vector2(100, 100),
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
      position: Vector2(100, 140),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 16,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Rest Button
    add(ButtonComponent(
      label: 'Rest (Recover 30% Health)',
      onPressed: () {
        if (!hasRested) {
          final healAmount = (player.maxHealth * 0.3).round();
          player.currentHealth =
              (player.currentHealth + healAmount).clamp(0, player.maxHealth);
          hasRested = true;
          _updateHealthText();
        }
      },
      position: Vector2(100, 200),
    ));

    // Upgrade Button
    add(ButtonComponent(
      label: 'Upgrade a Card',
      onPressed: () {
        if (!hasUpgraded && playerCards.isNotEmpty) {
          final upgradePanel = CardUpgradePanel(
            cards: List<Card>.from(playerCards),
            onCardUpgraded: (card) {
              hasUpgraded = true;
            },
            onClose: (panel) {
              panel.removeFromParent();
            },
          );
          add(upgradePanel);
        }
      },
      position: Vector2(100, 280),
    ));

    // View/Remove Cards Button
    add(ButtonComponent(
      label: 'View/Remove Cards',
      onPressed: () {
        if (!hasRemovedCard && playerCards.length > 1) {
          final deckPanel = DeckViewPanel(
            cards: List<Card>.from(playerCards),
            onCardRemoved: (card) {
              player.deck.removeCard(card);
              playerCards.remove(card);
              hasRemovedCard = true;
            },
            onClose: (panel) {
              panel.removeFromParent();
            },
          );
          add(deckPanel);
        }
      },
      position: Vector2(100, 360),
    ));

    // Continue Button
    add(ButtonComponent(
      label: 'Continue',
      onPressed: () => SceneManager().popScene(),
      position: Vector2(100, 440),
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
}
