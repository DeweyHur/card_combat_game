import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/game/map/map_generator.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/expedition_map_component.dart';
import 'package:flame/components.dart';

class ExpeditionScene extends BaseScene {
  late final MapStage mapStage;
  bool _mapAdded = false;

  ExpeditionScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.blueGrey.shade900, options: options);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Generate the map for the expedition
    mapStage = MapGenerator().generate();
    // Log to verify map structure
    GameLogger.info(LogCategory.game, 'Expedition Map:');
    for (int row = 0; row < mapStage.rows.length; row++) {
      final nodes = mapStage.rows[row];
      GameLogger.info(LogCategory.game, 'Row $row:');
      for (final node in nodes) {
        GameLogger.info(
          LogCategory.game,
          '  Node (col: [33m${node.col}[0m, type: [36m${node.type.toString().split('.').last}[0m) -> next: ${node.nextIndices}',
        );
      }
    }
  }

  @override
  void onMount() {
    super.onMount();
    if (!_mapAdded && size.x > 0 && size.y > 0) {
      add(ExpeditionMapComponent(
        mapStage: mapStage,
        playerRow: mapStage.rows.length - 1, // Start at bottom row
        playerCol: 0, // Start at first col (can be changed for pathing)
        size: size,
        position: Vector2.zero(),
      ));
      _mapAdded = true;
    }
  }
}
