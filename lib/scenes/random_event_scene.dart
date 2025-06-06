import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/random_event.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'dart:math';

class RandomEventScene extends BaseScene {
  late final PlayerRun player;
  late final RandomEvent event;
  bool hasChosen = false;
  final Random _random = Random();

  RandomEventScene({required Map<String, dynamic> options})
      : super(sceneBackgroundColor: material.Colors.brown.shade200) {
    player = options['player'] as PlayerRun;
    event = options['event'] as RandomEvent;
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

    // Add title
    add(TextComponent(
      text: event.title,
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 32,
          fontWeight: material.FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 50),
    ));

    // Add description
    add(TextComponent(
      text: event.description,
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 100),
    ));

    // Add choices
    for (int i = 0; i < event.choices.length; i++) {
      final choice = event.choices[i];
      add(SimpleButtonComponent.text(
        text: choice.text,
        size: Vector2(300, 50),
        color: material.Colors.blue,
        onPressed: () {
          if (!hasChosen) {
            hasChosen = true;
            final outcome = choice.outcome;
            final isSuccess = _random.nextDouble() < outcome.successChance;
            final message = isSuccess
                ? outcome.successReward(player)
                : outcome.failurePenalty(player);

            // Show outcome message
            add(TextComponent(
              text: message,
              position: Vector2(100.0, 300.0),
              textRenderer: TextPaint(
                style: const material.TextStyle(
                  fontSize: 18,
                  color: material.Colors.black87,
                ),
              ),
            ));

            // Continue button
            add(SimpleButtonComponent.text(
              text: 'Continue',
              size: Vector2(200, 50),
              color: material.Colors.green,
              onPressed: () => SceneManager().popScene(),
              position: Vector2(100.0, 360.0),
            ));
          }
        },
        position: Vector2(100.0, 200.0 + i * 60.0),
      ));
    }
  }
}
