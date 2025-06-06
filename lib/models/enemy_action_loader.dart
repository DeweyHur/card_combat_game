import 'package:card_combat_app/models/game_character.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_card.dart';
import 'game_character.dart' show StatusEffect;

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

Future<Map<String, List<EnemyAction>>> loadEnemyActionsFromCsv(
    String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);

  final Map<String, List<EnemyAction>> actionsByEnemy = {};
  for (final row in dataRows) {
    final enemy = row[0] as String;
    final action = EnemyAction(
      actionName: row[1] as String,
      description: row[2] as String,
      type: row[3] as String,
      value: int.parse(row[4].toString()),
      statusEffect: row[5] != null && row[5].toString().isNotEmpty
          ? row[5].toString()
          : null,
      statusDuration: row[6] != null && row[6].toString().isNotEmpty
          ? int.tryParse(row[6].toString())
          : null,
      probability: double.parse(row[7].toString()),
    );
    actionsByEnemy.putIfAbsent(enemy, () => []).add(action);
  }
  return actionsByEnemy;
}

GameCard enemyActionToGameCard(EnemyAction action) {
  return GameCard(
    name: action.actionName,
    description: action.description,
    type: CardType.values
        .firstWhere((e) => e.toString().split('.').last == action.type),
    value: action.value,
    cost: 1, // Enemy cards don't use cost
    statusEffectToApply:
        action.statusEffect != null && action.statusEffect!.isNotEmpty
            ? StatusEffect.values.firstWhere(
                (e) => e.toString().split('.').last == action.statusEffect)
            : null,
    statusDuration: action.statusDuration,
    color: "red",
    target: "player", // Enemy actions target player by default
  );
}
