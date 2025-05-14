import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';

class PlayerDetailPanel extends BasePanel {
  late PlayerBase player;
  late TextComponent nameText;
  late TextComponent statsText;
  late TextComponent descriptionText;
  late TextComponent deckText;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;

  PlayerDetailPanel() {
    player = Knight();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loading...');

    // Add name + emoji at the top
    nameEmojiComponent = NameEmojiComponent(character: player);
    addToVerticalStack(nameEmojiComponent, 60);

    // Add stats row
    statsRow = StatsRow(character: player);
    addToVerticalStack(statsRow, 20);

    descriptionText = TextComponent(
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    addToVerticalStack(descriptionText, 20);

    deckText = TextComponent(
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
    addToVerticalStack(deckText, 20);

    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loaded successfully');
    updateUI();
  }

  @override
  void onMount() {
    super.onMount();
    // Set initial player from DataController if available
    final selectedPlayer = DataController.instance.get<PlayerBase>('selectedPlayer');
    if (selectedPlayer != null) {
      player = selectedPlayer;
    }

    // Watch for changes to selectedPlayer
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is PlayerBase) {
        updatePlayer(value);
      }
    });
  }

  void updatePlayer(PlayerBase newPlayer) {
    player = newPlayer;
    nameEmojiComponent.updateCharacter(newPlayer);
    statsRow.setCharacter(player);
    descriptionText.text = player.description;
    deckText.text = 'Starting Deck: ${player.deck.length} cards';
  }

  @override
  void updateUI() {
    // Update any UI elements if needed
  }
} 