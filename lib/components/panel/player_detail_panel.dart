import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/components/panel/base_player_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerDetailPanel extends BasePlayerPanel {
  PlayerDetailPanel() : super(player: Knight());

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
    updateDescription(player.description);
  }

  @override
  void updateUI() {
    super.updateUI();
    updateDescription(player.description);
  }
} 