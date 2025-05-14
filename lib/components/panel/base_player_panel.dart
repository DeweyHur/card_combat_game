import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

abstract class BasePlayerPanel extends BasePanel {
  late PlayerBase player;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;
  late TextComponent classDescriptionText;
  late TextComponent descriptionText;

  BasePlayerPanel({required this.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiComponent = NameEmojiComponent(character: player);
    addToVerticalStack(nameEmojiComponent, 60);
    statsRow = StatsRow(character: player);
    addToVerticalStack(statsRow, 40);
    classDescriptionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    addToVerticalStack(classDescriptionText, 20);
    descriptionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    addToVerticalStack(descriptionText, 20);
  }

  void updatePlayer(PlayerBase newPlayer) {
    player = newPlayer;
    nameEmojiComponent.updateCharacter(newPlayer);
    statsRow.setCharacter(player);
    updateUI();
  }

  void updateClassDescription(String description) {
    classDescriptionText.text = description;
  }

  void updateDescription(String description) {
    descriptionText.text = description;
  }

  @override
  void updateUI() {
    statsRow.updateUI();
  }
} 