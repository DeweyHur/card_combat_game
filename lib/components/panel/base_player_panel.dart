import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/multiline_text_component.dart';

abstract class BasePlayerPanel extends BasePanel {
  late GameCharacter player;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;
  late MultilineTextComponent descriptionText;

  BasePlayerPanel({required this.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiComponent = NameEmojiComponent(character: player);
    resetVerticalStack();
    addToVerticalStack(nameEmojiComponent, 60);
    statsRow = StatsRow(character: player);
    addToVerticalStack(statsRow, 40);
    descriptionText = MultilineTextComponent(
      text: '',
      style: const TextStyle(color: Colors.white, fontSize: 16),
      maxWidth: size.x,
    );
    addToVerticalStack(descriptionText, -60);
  }

  void updatePlayer(GameCharacter newPlayer) {
    player = newPlayer;
    nameEmojiComponent.updateCharacter(newPlayer);
    statsRow.setCharacter(player);
    updateUI();
  }

  void updateDescription(String description) {
    descriptionText.text = description;
  }

  @override
  void updateUI() {
    statsRow.updateUI();
  }
} 