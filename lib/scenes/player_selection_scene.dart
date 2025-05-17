import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/player_selection_layout.dart';
import 'base_scene.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerSelectionScene extends BaseScene {
  late final List<GameCharacter> players;
  late final List<GameCharacter> enemies;
  late final PlayerSelectionLayout layout;
  late GameCharacter selectedEnemy;

  PlayerSelectionScene()
      : super(
          sceneBackgroundColor: const Color(0xFF2C3E50),
        ) {
    players = DataController.instance.get<List<GameCharacter>>('players') ?? [];
    enemies = DataController.instance.get<List<GameCharacter>>('enemies') ?? [];
    // Randomly select an enemy
    final random = DateTime.now().millisecondsSinceEpoch %
        (enemies.isNotEmpty ? enemies.length : 1);
    selectedEnemy = enemies.isNotEmpty
        ? enemies[random]
        : GameCharacter(
            name: 'Unknown',
            maxHealth: 1,
            attack: 1,
            defense: 1,
            emoji: '?',
            color: 'grey',
            imagePath: '',
            soundPath: '',
            description: '',
            deck: [],
            maxEnergy: 3);
    DataController.instance.set('selectedEnemy', selectedEnemy);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loading...');
    layout = PlayerSelectionLayout();
    add(layout);
    GameLogger.info(LogCategory.game, 'Player selection started');
  }
}
