import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';

abstract class BasePlayerPanel extends BasePanel {
  late PlayerBase player;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;

  BasePlayerPanel({required this.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiComponent = NameEmojiComponent(character: player);
    addToVerticalStack(nameEmojiComponent, 60);
    statsRow = StatsRow(character: player);
    addToVerticalStack(statsRow, 40);
  }

  void updatePlayer(PlayerBase newPlayer) {
    player = newPlayer;
    nameEmojiComponent.updateCharacter(newPlayer);
    statsRow.setCharacter(player);
    updateUI();
  }

  @override
  void updateUI() {
    statsRow.updateUI();
  }
} 