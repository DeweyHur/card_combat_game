import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/camp_event_panel.dart';

class CampEventScene extends BaseScene {
  late final Player player;

  CampEventScene({required Map<String, dynamic> options})
      : super(sceneBackgroundColor: material.Colors.brown.shade200) {
    player = options['player'] as Player;
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

    // Add camp event panel
    add(CampEventPanel(
      player: player,
      playerCards: player.deck.cards,
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.8),
    ));
  }
}
