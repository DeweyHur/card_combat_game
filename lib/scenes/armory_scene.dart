import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/armory_scene_layout.dart';
import 'base_scene.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/models/game_character.dart';

class ArmoryScene extends BaseScene with TapCallbacks {
  late final ArmorySceneLayout _layout;

  ArmoryScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: const Color(0xFF222244), options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Set selectedPlayer from options if provided
    final player = options?['player'];
    if (player != null) {
      // Import DataController and GameCharacter if not already
      // ignore: import_of_legacy_library_into_null_safe
      DataController.instance.set('selectedPlayer', player);
    }
    _layout = ArmorySceneLayout(options: options);
    add(_layout);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout.onGameResize(size);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _layout.handleTap(event.canvasPosition);
  }

  @override
  void onMount() {
    super.onMount();
    // Log the current state of the selected player when the scene is mounted
    final currentPlayer =
        DataController.instance.get<GameCharacter>('selectedPlayer');
    GameLogger.info(LogCategory.game,
        '[ARMORY] Scene mounted with player: ${currentPlayer?.name}');
    GameLogger.info(LogCategory.game,
        '[ARMORY] Player stats - Health: ${currentPlayer?.maxHealth}, Attack: ${currentPlayer?.attack}, Defense: ${currentPlayer?.defense}');
    GameLogger.info(LogCategory.game,
        '[ARMORY] Player deck size: ${currentPlayer?.deck.length}');
    GameLogger.info(LogCategory.game,
        '[ARMORY] Player equipment: ${currentPlayer?.equipment}');
  }
}
