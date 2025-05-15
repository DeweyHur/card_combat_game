import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/base_player_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerDetailPanel extends BasePlayerPanel {
  PlayerDetailPanel()
      : super(player: DataController.instance.get<GameCharacter>('selectedPlayer') ?? _emptyPlayer());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loading...');
    GameLogger.debug(LogCategory.ui, 'PlayerDetailPanel loaded successfully');
  }

  @override
  void onMount() {
    super.onMount();
    updateUI();
    final selectedPlayer = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (selectedPlayer != null) {
      player = selectedPlayer;
    }
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is GameCharacter) {
        updatePlayer(value);
      }
    });
  }

  @override
  void updatePlayer(dynamic newPlayer) {
    super.updatePlayer(newPlayer);
    updateDescription(player.description);
  }

  @override
  void updateUI() {
    super.updateUI();
    updateDescription(player.description);
  }
}

GameCharacter _emptyPlayer() => GameCharacter(
  name: 'Unknown',
  maxHealth: 1,
  attack: 0,
  defense: 0,
  emoji: '?',
  color: 'grey',
  imagePath: '',
  soundPath: '',
  description: 'No player selected',
  deck: [],
); 