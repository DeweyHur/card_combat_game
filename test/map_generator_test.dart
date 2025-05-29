import 'package:card_combat_app/game/map/map_generator.dart';
import 'package:card_combat_app/utils/game_logger.dart';

void main() {
  final generator = MapGenerator(seed: 42);
  final map = generator.generate();

  GameLogger.info(LogCategory.game, 'Generated Map:');
  for (int row = 0; row < map.rows.length; row++) {
    final nodes = map.rows[row];
    GameLogger.info(LogCategory.game, 'Row $row:');
    for (final node in nodes) {
      GameLogger.info(
        LogCategory.game,
        '  Node (col: [33m${node.col}[0m, type: [36m${node.type.toString().split('.').last}[0m) -> next: ${node.nextIndices}',
      );
    }
  }
}
