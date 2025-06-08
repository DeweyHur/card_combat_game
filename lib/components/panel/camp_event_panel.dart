import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/components/simple_button_component.dart';
import 'dart:ui';

class CampEventPanel extends BasePanel {
  final PlayerRun player;
  final List<CardRun> playerCards;
  bool _hasRested = false;
  bool _hasRemovedCard = false;

  CampEventPanel({
    required this.player,
    required this.playerCards,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateUI();
  }

  void _updateUI() {
    // Clear existing components
    children.clear();

    // Add title
    add(TextComponent(
      text: 'Camp',
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 32,
          color: material.Colors.white,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    ));

    // Add rest button if not rested
    if (!_hasRested) {
      add(SimpleButtonComponent.text(
        text: 'Rest (Heal 20% HP)',
        position: Vector2(size.x / 2, size.y * 0.3),
        size: Vector2(200, 50),
        color: material.Colors.green,
        onPressed: () {
          final healAmount = (player.maxHealth * 0.2).round();
          player.heal(healAmount);
          _hasRested = true;
          _updateUI();
          GameLogger.info(
              LogCategory.game, 'Player rested and healed for $healAmount HP');
        },
      ));
    }

    // Add remove card button if not removed
    if (!_hasRemovedCard) {
      add(SimpleButtonComponent.text(
        text: 'Remove a Card',
        position: Vector2(size.x / 2, size.y * 0.4),
        size: Vector2(200, 50),
        color: material.Colors.orange,
        onPressed: () {
          // TODO: Implement card removal UI
          _hasRemovedCard = true;
          _updateUI();
          GameLogger.info(LogCategory.game, 'Player removed a card');
        },
      ));
    }

    // Add continue button
    add(SimpleButtonComponent.text(
      text: 'Continue',
      position: Vector2(size.x / 2, size.y * 0.8),
      size: Vector2(200, 50),
      color: material.Colors.blue,
      onPressed: () {
        SceneManager().popScene();
        GameLogger.info(LogCategory.game, 'Player continued from camp');
      },
    ));
  }

  @override
  void updateUI() {
    _updateUI();
  }
}
