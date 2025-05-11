import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
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
import 'package:card_combat_app/models/enemies/tung_tung_tung_sahur.dart';
import 'package:card_combat_app/models/enemies/trippi_troppi.dart';
import 'package:card_combat_app/models/enemies/trullimero_trullicina.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/layout/player_selection_layout.dart';
import 'base_scene.dart';

class PlayerSelectionScene extends BaseScene with TapCallbacks, HasGameRef {
  final List<PlayerBase> availablePlayers = [
    Knight(),
    Mage(),
    Sorcerer(),
    Paladin(),
    Warlock(),
    Fighter(),
  ];

  final List<EnemyBase> availableEnemies = [
    TungTungTungSahur(),
    TrippiTroppi(),
    TrullimeroTrullicina(),
  ];

  late final PlayerSelectionLayout _layout;
  PlayerBase? selectedPlayer;
  late EnemyBase selectedEnemy;

  PlayerSelectionScene() : super(
    sceneBackgroundColor: const Color(0xFF2C3E50),
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

    _layout = PlayerSelectionLayout(
      gameSize: game.size,
    );
    add(_layout);

    GameLogger.info(LogCategory.game, 'Player selection started');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final selectedPlayer = _layout.getSelectedPlayer(event.canvasPosition);
    if (selectedPlayer != null) {
      this.selectedPlayer = selectedPlayer;
      GameLogger.info(LogCategory.game, 'Player selected: ${selectedPlayer.name}');
    }
  }

  PlayerBase? getSelectedPlayer() => selectedPlayer;

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