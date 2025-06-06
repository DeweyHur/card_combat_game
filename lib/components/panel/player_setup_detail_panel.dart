import 'package:card_combat_app/models/player.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/multiline_text_component.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/layout/stats_row.dart';

class PlayerSetupDetailPanel extends BasePanel {
  late MultilineTextComponent descriptionText;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;
  PlayerSetup? setup;

  PlayerSetupDetailPanel() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    descriptionText = MultilineTextComponent(
      text: '',
      style: const TextStyle(color: Colors.white, fontSize: 16),
      maxWidth: size.x,
    );
    registerVerticalStackComponent('descriptionText', descriptionText, 0);

    GameLogger.debug(LogCategory.ui, 'PlayerSetupDetailPanel loading...');
    GameLogger.debug(
        LogCategory.ui, 'PlayerSetupDetailPanel loaded successfully');
  }

  @override
  void onMount() {
    super.onMount();
    updateUI();
  }

  void updateSetup(PlayerSetup newSetup) {
    setup = newSetup;
    if (isLoaded) {
      nameEmojiComponent = NameEmojiComponent(character: setup!);
      final playerRun = PlayerRun(setup!);
      statsRow = StatsRow(character: playerRun);
      resetVerticalStack();
      registerVerticalStackComponent('nameEmoji', nameEmojiComponent, 60);
      registerVerticalStackComponent('statsRow', statsRow, 20);
      updateDescription(setup!.template.description);
      updateUI();
    }
  }

  void updateUI() {
    if (setup != null) {
      updateDescription(setup!.template.description);
    }
  }

  void updateDescription(String description) {
    descriptionText.text = description;
  }
}
