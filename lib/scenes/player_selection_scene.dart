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

class PlayerSelectionScene extends BaseScene {
  final List<EnemyBase> availableEnemies = [
    TungTungTungSahur(),
    TrippiTroppi(),
    TrullimeroTrullicina(),
  ];

  late final PlayerSelectionLayout layout;
  late EnemyBase selectedEnemy;

  PlayerSelectionScene() : super(
    sceneBackgroundColor: const Color(0xFF2C3E50),
  ) {
    // Randomly select an enemy
    final random = DateTime.now().millisecondsSinceEpoch % availableEnemies.length;
    selectedEnemy = availableEnemies[random];
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