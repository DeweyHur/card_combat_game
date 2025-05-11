import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/mage.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/components/layout/player_selection_box.dart';
import 'package:card_combat_app/scenes/combat_scene.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/enemies/goblin.dart';
import 'package:card_combat_app/models/enemies/orc.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'base_scene.dart';

class PlayerSelectionScene extends BaseScene with TapCallbacks {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  final List<EnemyBase> availableEnemies = [
    Goblin(),
    Orc(),
  ];

  PlayerBase? selectedPlayer;
  late EnemyBase selectedEnemy;

  late TextComponent titleText;
  late List<PlayerSelectionBox> characterBoxes;
  late TextComponent enemyInfoText;

  PlayerSelectionScene() : super(
    backgroundColor: const Color(0xFF2C3E50),
  ) {
    // Randomly select an enemy
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[random];
  }

  @override
  Vector2 get size => gameRef.size;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loading...');

    // Add title
    titleText = TextComponent(
      text: 'Choose Your Character',
      position: Vector2(game.size.x / 2, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(titleText);

    // Add enemy info
    enemyInfoText = TextComponent(
      text: 'Your opponent: ${selectedEnemy.name} ${selectedEnemy.emoji}',
      position: Vector2(game.size.x / 2, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(enemyInfoText);

    // Create character selection boxes
    characterBoxes = [];

    final boxWidth = game.size.x * 0.8;
    final boxHeight = game.size.y * 0.15;
    final spacing = game.size.y * 0.015;
    final startX = (game.size.x - boxWidth) / 2;
    final startY = game.size.y * 0.2;  // Start lower to make room for enemy info

    for (var i = 0; i < availablePlayers.length; i++) {
      final y = startY + (i * (boxHeight + spacing));
      
      final box = PlayerSelectionBox(
        character: availablePlayers[i],
        position: Vector2(startX, y),
        size: Vector2(boxWidth, boxHeight),
        onSelected: () => _onCharacterSelected(i),
      );
      
      add(box);
      characterBoxes.add(box);
    }
    
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loaded successfully');
  }

  void _onCharacterSelected(int index) {
    GameLogger.info(LogCategory.game, 'Character selected: $index');
    try {
      selectedPlayer = availablePlayers[index];
      GameLogger.info(LogCategory.game, 'Player selected: ${selectedPlayer!.name}');
      
      SceneManager.instance.pushScene('combat', selectedPlayer, selectedEnemy);
      GameLogger.info(LogCategory.game, 'Transitioning to combat scene');
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.game, 'Error during character selection: $e\n$stackTrace');
    }
  }
} 