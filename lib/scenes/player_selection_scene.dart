import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/player_selection_layout.dart';
import 'base_scene.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSelectionScene extends BaseScene {
  late final List<PlayerRun> playerRuns;
  late final PlayerSelectionLayout layout;
  static const String _gameSessionKey = 'currentGameSession';

  PlayerSelectionScene({Map<String, dynamic>? options})
      : super(
          sceneBackgroundColor: const Color(0xFF2C3E50),
          options: options,
        ) {
    // Create PlayerRun instances for each template
    playerRuns = PlayerTemplate.templates.map((template) {
      final setup = PlayerSetup(template);
      return PlayerRun(setup);
    }).toList();

    // Check for existing game session
    _loadGameSession();
  }

  Future<void> _loadGameSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayerName = prefs.getString(_gameSessionKey);

    if (savedPlayerName != null) {
      final savedPlayer = PlayerTemplate.findByName(savedPlayerName);
      if (savedPlayer != null) {
        // Create PlayerSetup and load its saved state
        final playerSetup = PlayerSetup(savedPlayer);
        await playerSetup.loadFromLocalStorage();

        // Create PlayerRun from the setup
        final playerRun = PlayerRun(playerSetup);
        await playerRun.loadRunData();

        // Store in DataController for other components to access
        DataController.instance.set<PlayerRun>('currentPlayerRun', playerRun);
      }
    }
  }

  Future<void> _saveGameSession(PlayerRun playerRun) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameSessionKey, playerRun.name);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loading...');

    // Create layout with available player runs
    layout = PlayerSelectionLayout(
      playerRuns: playerRuns,
      onPlayerSelected: (PlayerRun playerRun) async {
        // Save to DataController
        DataController.instance.set<PlayerRun>('currentPlayerRun', playerRun);

        // Save game session
        await _saveGameSession(playerRun);

        GameLogger.info(LogCategory.game, 'Selected player: ${playerRun.name}');
      },
    );

    add(layout);
    GameLogger.info(LogCategory.game, 'Player selection started');
  }
}
