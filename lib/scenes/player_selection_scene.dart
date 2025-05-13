import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/enemies/tung_tung_tung_sahur.dart';
import 'package:card_combat_app/models/enemies/trippi_troppi.dart';
import 'package:card_combat_app/models/enemies/trullimero_trullicina.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/layout/player_selection_layout.dart';
import 'base_scene.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/enemies/ballerina_cappuccina.dart';
import 'package:card_combat_app/models/enemies/bobombini_goosini.dart';
import 'package:card_combat_app/models/enemies/bobrini_cocococini.dart';
import 'package:card_combat_app/models/enemies/bombardino_crocodilo.dart';
import 'package:card_combat_app/models/enemies/brr_brr_patapim.dart';
import 'package:card_combat_app/models/enemies/burbaloni_luliloli.dart';
import 'package:card_combat_app/models/enemies/capuccino_assasino.dart';
import 'package:card_combat_app/models/enemies/tralalero_tralala.dart';

class PlayerSelectionScene extends BaseScene {
    final availableEnemies = [
      TungTungTungSahur(),
      TrippiTroppi(),
      TrullimeroTrullicina(),
      BallerinaCappuccina(),
      BobombiniGoosini(),
      BobriniCocococini(),
      BombardinoCrocodilo(),
      BrrBrrPatapim(),
      BurbaloniLuliloli(),
      CapuccinoAssasino(),
      TralaleroTralala(),
    ];

  late final PlayerSelectionLayout layout;
  late EnemyBase selectedEnemy;

  PlayerSelectionScene() : super(
    sceneBackgroundColor: const Color(0xFF2C3E50),
  ) {
    // Set default selected player to Knight
    DataController.instance.set('selectedPlayer', Knight());
    // Randomly select an enemy
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[0];
    // Save selected enemy to DataController
    DataController.instance.set('selectedEnemy', selectedEnemy);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loading...');

    // Add layout
    layout = PlayerSelectionLayout();
    add(layout);

    GameLogger.info(LogCategory.game, 'Player selection started');
  }
} 