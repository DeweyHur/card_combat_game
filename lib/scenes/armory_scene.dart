import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/armory_scene_layout.dart';
import 'base_scene.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_combat_app/managers/static_data_manager.dart';

class ArmoryScene extends BaseScene with TapCallbacks {
  ArmorySceneLayout? _layout;
  static const String _lastSelectedPlayerKey = 'lastSelectedPlayer';

  ArmoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244), options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Try to get the last selected player from local storage
    final prefs = await SharedPreferences.getInstance();
    String? lastSelectedPlayerName = prefs.getString(_lastSelectedPlayerKey);

    // Get the player setup from DataController or use the last selected player
    PlayerSetup? playerSetup =
        DataController.instance.get<PlayerSetup>('selectedPlayerSetup');

    if (playerSetup == null) {
      // If no player setup is selected, try to get the last selected player
      if (lastSelectedPlayerName != null) {
        final template =
            StaticDataManager.findPlayerTemplate(lastSelectedPlayerName);
        if (template != null) {
          playerSetup = PlayerSetup(template);
        }
      }

      // If still no player setup, use the first player from templates
      if (playerSetup == null) {
        final templates = StaticDataManager.playerTemplates;
        if (templates.isNotEmpty) {
          playerSetup = PlayerSetup(templates.first);
        } else {
          GameLogger.error(
              LogCategory.game, '[ARMORY] No player templates available');
          return;
        }
      }

      // Save the player setup to DataController and local storage
      DataController.instance.set('selectedPlayerSetup', playerSetup);
      await prefs.setString(_lastSelectedPlayerKey, playerSetup.template.name);

      GameLogger.info(LogCategory.game,
          '[ARMORY] No player setup selected, using: ${playerSetup.template.name}');
    } else {
      // Save the player setup to local storage
      await prefs.setString(_lastSelectedPlayerKey, playerSetup.template.name);
      GameLogger.info(LogCategory.game,
          '[ARMORY] Using selected player setup: ${playerSetup.template.name}');
    }

    _layout = ArmorySceneLayout(
      playerSetup: playerSetup,
      options: options,
    );
    add(_layout!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_layout != null) {
      _layout!.size = size; // Update layout size when game is resized
    }
  }

  @override
  void onMount() {
    super.onMount();
    // Log the current state of the selected player setup when the scene is mounted
    final currentSetup =
        DataController.instance.get<PlayerSetup>('selectedPlayerSetup');
    GameLogger.info(LogCategory.game,
        '[ARMORY] Scene mounted with player setup: [32m[1m[4m[7m${currentSetup?.template.name}[0m');
  }
}
