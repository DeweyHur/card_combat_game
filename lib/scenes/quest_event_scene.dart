import 'dart:math';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/quest_data.dart';
import 'package:card_combat_app/components/simple_button_component.dart';

class QuestEventScene extends BaseScene {
  late final PlayerRun player;
  late final QuestRun quest;
  bool hasChosen = false;
  final Random _random = Random();

  QuestEventScene({required Map<String, dynamic> options})
      : super(sceneBackgroundColor: material.Colors.brown.shade200) {
    player = options['player'] as PlayerRun;
    quest = options['quest'] as QuestRun;
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
      text: quest.template.title,
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
      text: quest.template.description,
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
    for (int i = 0; i < quest.template.choices.length; i++) {
      final choice = quest.template.choices[i];
      add(SimpleButtonComponent.text(
        text: choice.text,
        size: Vector2(300, 50),
        color: material.Colors.blue,
        onPressed: () {
          if (!hasChosen) {
            hasChosen = true;
            final isSuccess = _random.nextDouble() < choice.successChance;
            String message;
            if (isSuccess) {
              // Apply success reward
              switch (choice.successRewardType) {
                case 'equipment':
                  // You may want to implement equipment logic here
                  message =
                      'You gained equipment: ${choice.successRewardValue}';
                  break;
                case 'health':
                  final amount = int.tryParse(choice.successRewardValue) ?? 0;
                  player.heal(amount);
                  message = 'You healed $amount health!';
                  break;
                case 'status':
                  message = 'Status effect: ${choice.successRewardValue}';
                  break;
                default:
                  message = 'Success!';
              }
            } else {
              // Apply failure penalty
              switch (choice.failurePenaltyType) {
                case 'equipment':
                  message = 'You lost equipment: ${choice.failurePenaltyValue}';
                  break;
                case 'health':
                  final amount = int.tryParse(choice.failurePenaltyValue) ?? 0;
                  player.takeDamage(amount);
                  message = 'You lost $amount health!';
                  break;
                case 'status':
                  message = 'Status effect: ${choice.failurePenaltyValue}';
                  break;
                default:
                  message = 'Failure!';
              }
            }

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
