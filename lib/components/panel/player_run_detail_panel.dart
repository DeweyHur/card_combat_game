import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/layout/stats_row.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/utils/color_utils.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/layout/multiline_text_component.dart';

class PlayerRunDetailPanel extends BasePanel with AreaFillerMixin {
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;
  late MultilineTextComponent descriptionText;
  PlayerRun? player;

  PlayerRunDetailPanel();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    descriptionText = MultilineTextComponent(
      text: '',
      style: const TextStyle(color: Colors.white, fontSize: 16),
      maxWidth: size.x,
    );
    registerVerticalStackComponent('descriptionText', descriptionText, 0);

    if (player != null) {
      nameEmojiComponent = NameEmojiComponent(character: player!);
      statsRow = StatsRow(character: player!);
      resetVerticalStack();
      registerVerticalStackComponent('nameEmoji', nameEmojiComponent, 60);
      registerVerticalStackComponent('statsRow', statsRow, 20);
      updateDescription(player!.description);
    }

    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loading...');
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loaded successfully');
  }

  @override
  void onMount() {
    super.onMount();
    updateUI();
    final selectedPlayer =
        DataController.instance.get<PlayerRun>('selectedPlayer');
    if (selectedPlayer != null) {
      updatePlayer(selectedPlayer);
    }
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is PlayerRun) {
        updatePlayer(value);
      }
    });
  }

  void updatePlayer(PlayerRun newPlayer) {
    player = newPlayer;
    if (isLoaded) {
      nameEmojiComponent = NameEmojiComponent(character: player!);
      statsRow = StatsRow(character: player!);
      resetVerticalStack();
      registerVerticalStackComponent('nameEmoji', nameEmojiComponent, 60);
      registerVerticalStackComponent('statsRow', statsRow, 20);
      updateDescription(player!.description);
      updateUI();
    }
  }

  @override
  void updateUI() {
    if (player != null) {
      nameEmojiComponent.updateCharacter(player!);
      statsRow.setCharacter(player!);
      updateDescription(player!.description);
    }
  }

  void updateDescription(String description) {
    descriptionText.text = description;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (player != null) {
      drawAreaFiller(
        canvas,
        colorFromString(player!.color).withAlpha(77),
        borderColor: colorFromString(player!.color),
        borderWidth: 2.0,
      );
    }
  }
}
