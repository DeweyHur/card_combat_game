import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/game/map/map_generator.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/expedition_map_component.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/player.dart';

class ExpeditionScene extends BaseScene {
  late final MapStage mapStage;
  bool _mapAdded = false;
  int playerRow = 0;
  int playerCol = 0;
  ExpeditionMapComponent? mapComponent;
  List<(int, int)> selectableNodes = [];
  late final PlayerRun player;

  ExpeditionScene({required Map<String, dynamic> options})
      : super(sceneBackgroundColor: Colors.blueGrey.shade900) {
    player = options['player'] as PlayerRun;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Generate the map for the expedition
    mapStage = MapGenerator().generate();
    // Start player at bottom row, col 0
    playerRow = mapStage.rows.length - 1;
    playerCol = 0;
    _updateSelectableNodes();
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
      mapComponent = ExpeditionMapComponent(
        mapStage: mapStage,
        playerRow: playerRow,
        playerCol: playerCol,
        selectableNodes: selectableNodes,
        onNodeTap: _onNodeTap,
        size: size,
        position: Vector2.zero(),
      );
      add(mapComponent!);
      _mapAdded = true;
    }
  }

  void updatePlayerPosition(int newRow, int newCol) {
    playerRow = newRow;
    playerCol = newCol;
    _updateSelectableNodes();
    if (mapComponent != null) {
      mapComponent!.playerRow = playerRow;
      mapComponent!.playerCol = playerCol;
      mapComponent!.selectableNodes = selectableNodes;
    }
  }

  void _updateSelectableNodes() {
    selectableNodes = [];
    if (playerRow <= 0) return; // No next row
    final node = mapStage.rows[playerRow][playerCol];
    final nextRow = playerRow - 1;
    for (final nextCol in node.nextIndices) {
      selectableNodes.add((nextRow, nextCol));
    }
  }

  void _onNodeTap(int row, int col) {
    // Only allow moving to selectable nodes
    if (selectableNodes.contains((row, col))) {
      updatePlayerPosition(row, col);
      // Trigger node event
      final node = mapStage.rows[row][col];
      switch (node.type) {
        case MapNodeType.battle:
        case MapNodeType.boss:
          SceneManager().pushScene('combat', options: {
            'nodeType': node.type.toString(),
            'row': row,
            'col': col,
          });
          break;
        case MapNodeType.quest:
          SceneManager().pushScene('quest_event', options: {
            'nodeType': node.type.toString(),
            'row': row,
            'col': col,
          });
          break;
        case MapNodeType.event:
          SceneManager().pushScene('random_event', options: {
            'nodeType': node.type.toString(),
            'row': row,
            'col': col,
          });
          break;
        case MapNodeType.camp:
          DataController.instance.set<PlayerRun>('currentPlayerRun', player);
          SceneManager().pushScene('camp_event', options: {
            'nodeType': node.type.toString(),
            'row': row,
            'col': col,
          });
          break;
        case MapNodeType.start:
          // No event for start node
          break;
      }
    }
  }
}
