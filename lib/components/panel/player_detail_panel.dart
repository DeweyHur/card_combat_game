import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_player_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerDetailPanel extends BasePlayerPanel {
  late TextComponent descriptionText;
  late TextComponent deckText;

  PlayerDetailPanel() : super(player: Knight());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loading...');

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
  }

  @override
  void onMount() {
    super.onMount();
    updateUI();
    final selectedPlayer = DataController.instance.get<PlayerBase>('selectedPlayer');
    if (selectedPlayer != null) {
      player = selectedPlayer;
    }
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is PlayerBase) {
        updatePlayer(value);
      }
    });
  }

  @override
  void updatePlayer(PlayerBase newPlayer) {
    super.updatePlayer(newPlayer);
    descriptionText.text = player.description;
    deckText.text = 'Starting Deck: [36m${player.deck.length}[0m cards';
  }

  @override
  void updateUI() {
    super.updateUI();
    descriptionText.text = player.description;
    deckText.text = 'Starting Deck: [36m${player.deck.length}[0m cards';
  }
} 