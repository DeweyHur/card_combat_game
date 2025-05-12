import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';

class PlayerDetailPanel extends BasePanel {
  late PlayerBase player;
  late TextComponent nameText;
  late TextComponent statsText;
  late TextComponent descriptionText;
  late TextComponent energyText;
  late TextComponent deckText;
  late NameEmojiComponent nameEmojiComponent;

  PlayerDetailPanel() {
    player = Knight();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loading...');

    // Add name + emoji at the top
    nameEmojiComponent = NameEmojiComponent(player: player);
    add(nameEmojiComponent);

    statsText = TextComponent(
      text: 'HP: ${player.maxHealth} | ATK: ${player.attack} | DEF: ${player.defense}',
      position: Vector2(size.x * 0.5, 0),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(statsText);

    descriptionText = TextComponent(
      text: player.description,
      position: Vector2(size.x * 0.5, 130),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(descriptionText);

    energyText = TextComponent(
      text: 'Max Energy: ${player.maxEnergy}',
      position: Vector2(size.x * 0.5, 180),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(energyText);

    deckText = TextComponent(
      text: 'Starting Deck: ${player.deck.length} cards',
      position: Vector2(size.x * 0.5, 230),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(deckText);

    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loaded successfully');
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
    nameEmojiComponent.updatePlayer(newPlayer);
    statsText.text = 'HP: ${player.maxHealth} | ATK: ${player.attack} | DEF: ${player.defense}';
    descriptionText.text = player.description;
    energyText.text = 'Max Energy: ${player.maxEnergy}';
    deckText.text = 'Starting Deck: ${player.deck.length} cards';
  }

  @override
  void updateUI() {
    // Update any UI elements if needed
  }
} 