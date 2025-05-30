import 'dart:math';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/quest_data.dart';

class QuestEventScene extends BaseScene {
  QuestEventScene({Map<String, dynamic>? options})
      : super(
            sceneBackgroundColor: material.Colors.blue.shade100,
            options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(QuestEventPanel());
  }
}

class QuestEventPanel extends PositionComponent {
  late final Player player;
  bool hasChosen = false;
  late final QuestData quest;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize player from CSV
    player = await Player.loadFromCSV('Warrior');

    // Load quests and select one randomly
    final quests = await QuestData.loadQuests();
    quest = quests[_random.nextInt(quests.length)];

    // Title
    add(TextComponent(
      text: 'Quest Event',
      position: Vector2(100.0, 50.0),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 32,
          color: material.Colors.black,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    ));

    // Quest Title
    add(TextComponent(
      text: quest.title,
      position: Vector2(100.0, 100.0),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 24,
          color: material.Colors.black87,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    ));

    // Quest Description
    add(TextComponent(
      text: quest.description,
      position: Vector2(100.0, 140.0),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          fontSize: 18,
          color: material.Colors.black87,
        ),
      ),
    ));

    // Choice Buttons
    for (int i = 0; i < quest.choices.length; i++) {
      final choice = quest.choices[i];
      add(ButtonComponent(
        label: choice.text,
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
            add(ButtonComponent(
              label: 'Continue',
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
