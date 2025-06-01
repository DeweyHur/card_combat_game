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
    final selectedPlayer =
        DataController.instance.get<GameCharacter>('selectedPlayer');
    if (selectedPlayer == null) {
      // TODO: Handle case when no player is selected
      return;
    }
    _layout = ArmorySceneLayout(
      player: selectedPlayer,
      position: Vector2.zero(),
      size: Vector2(0, 0), // Initialize with zero size
    );
    add(_layout);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout.size = size; // Update layout size when game is resized
    _layout.onGameResize(size);
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
