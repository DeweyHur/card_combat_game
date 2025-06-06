import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/camp_event_panel.dart';
import 'package:card_combat_app/models/game_card.dart';

class CampEventScene extends BaseScene {
  late final PlayerRun playerRun;

  CampEventScene({required Map<String, dynamic> options})
      : super(sceneBackgroundColor: material.Colors.brown.shade200) {
    playerRun = options['player'] as PlayerRun;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    add(RectangleComponent(
      size: size,
      paint: material.Paint()..color = material.Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Convert CardRun list to GameCard list
    final gameCards = playerRun.deck.map((cardRun) {
      final template = cardRun.setup.template;
      return GameCard(
        name: template.name,
        description: template.description,
        type: _mapCardType(template.type),
        value: template.damage,
        cost: template.cost,
        color: _determineCardColor(template.rarity),
        target: _determineCardTarget(template.type),
      );
    }).toList();

    // Add camp event panel
    add(CampEventPanel(
      player: playerRun,
      playerCards: gameCards,
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.8),
    ));
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
