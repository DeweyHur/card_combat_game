import 'package:card_combat_app/models/card.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/camp_event_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class CampEventScene extends BaseScene {
  CampEventScene({Map<String, dynamic>? options})
      : super(
            sceneBackgroundColor: material.Colors.brown.shade200,
            options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final playerRun =
        DataController.instance.get<PlayerRun>('currentPlayerRun');
    if (playerRun == null) {
      GameLogger.error(LogCategory.game, 'No player run found for camp event');
      return;
    }

    // Add background
    add(RectangleComponent(
      size: size,
      paint: material.Paint()..color = material.Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add camp event panel
    add(CampEventPanel(
      player: playerRun,
      playerCards: playerRun.deck,
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.8),
    ));

    GameLogger.info(LogCategory.game, 'Camp event scene loaded');
  }

  CardType _mapCardType(String type) {
    switch (type.toLowerCase()) {
      case 'attack':
        return CardType.attack;
      case 'defense':
      case 'shield':
        return CardType.shield;
      case 'heal':
        return CardType.heal;
      case 'cure':
        return CardType.cure;
      case 'skill':
        return CardType.statusEffect;
      default:
        return CardType.attack;
    }
  }

  String _determineCardColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'blue';
      case 'uncommon':
        return 'green';
      case 'rare':
        return 'purple';
      case 'epic':
        return 'orange';
      case 'legendary':
        return 'red';
      default:
        return 'blue';
    }
  }

  String _determineCardTarget(String type) {
    switch (type.toLowerCase()) {
      case 'heal':
      case 'shield':
        return 'player';
      case 'cure':
        return 'self';
      default:
        return 'enemy';
    }
  }
}
