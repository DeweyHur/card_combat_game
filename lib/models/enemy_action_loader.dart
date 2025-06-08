import 'package:card_combat_app/models/enemy_action.dart';
import 'package:card_combat_app/utils/game_logger.dart';

Future<Map<String, List<EnemyActionRun>>> loadEnemyActionsFromCsv(
    String path) async {
  try {
    await EnemyActionTemplate.loadFromCsv(path);
    final Map<String, List<EnemyActionRun>> enemyActionsByName = {};

    for (final template in EnemyActionTemplate.templates) {
      final actionRun = EnemyActionRun.fromTemplate(template, 'enemy');
      enemyActionsByName.putIfAbsent(template.type, () => []).add(actionRun);
    }

    return enemyActionsByName;
  } catch (e) {
    GameLogger.error(LogCategory.data, 'Error loading enemy actions: $e');
    return {};
  }
}
