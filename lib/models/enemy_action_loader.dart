import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class EnemyAction {
  final String actionName;
  final String description;
  final String type;
  final int value;
  final String? statusEffect;
  final int? statusDuration;
  final double probability;

  EnemyAction({
    required this.actionName,
    required this.description,
    required this.type,
    required this.value,
    this.statusEffect,
    this.statusDuration,
    required this.probability,
  });
}

Future<Map<String, List<EnemyAction>>> loadEnemyActionsFromCsv(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);

  final Map<String, List<EnemyAction>> actionsByEnemy = {};
  for (final row in dataRows) {
    final enemy = row[0] as String;
    final action = EnemyAction(
      actionName: row[1] as String,
      description: row[2] as String,
      type: row[3] as String,
      value: int.parse(row[4].toString()),
      statusEffect: (row[5] as String).isNotEmpty ? row[5] as String : null,
      statusDuration: (row[6] as String).isNotEmpty ? int.parse(row[6].toString()) : null,
      probability: double.parse(row[7].toString()),
    );
    actionsByEnemy.putIfAbsent(enemy, () => []).add(action);
  }
  return actionsByEnemy;
} 