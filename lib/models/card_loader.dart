import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';

/// Loads all cards from CSV and returns a map: owner name -> List<GameCard>
Future<Map<String, List<GameCard>>> loadCardsByOwnerFromCsv(
    String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');

  // Assume header: owner,name,description,type,value,cost,statusEffect,statusDuration,color
  final dataRows = rows.skip(1);

  final Map<String, List<GameCard>> ownerCards = {};

  for (final row in dataRows) {
    try {
      if (row.length < 9) {
        GameLogger.warning(
            LogCategory.data, 'Skipping malformed card row: $row');
        continue;
      }
      final owner = row[0] as String;
      CardType cardType;
      try {
        cardType = CardType.values.firstWhere(
          (e) => e.toString().split('.').last == row[3],
        );
      } catch (e) {
        GameLogger.warning(
            LogCategory.data, 'Unknown card type: \'${row[3]}\' in row: $row');
        continue;
      }
      StatusEffect? statusEffect;
      if (row[6] != null && row[6].toString().isNotEmpty && row[6] != 'null') {
        try {
          statusEffect = StatusEffect.values.firstWhere(
            (e) => e.toString().split('.').last == row[6],
          );
        } catch (e) {
          GameLogger.warning(LogCategory.data,
              'Unknown status effect: \'${row[6]}\' in row: $row');
          statusEffect = null;
        }
      }
      final card = GameCard(
        name: row[1] as String,
        description: row[2] as String,
        type: cardType,
        value: int.tryParse(row[4].toString()) ?? 0,
        cost: int.tryParse(row[5].toString()) ?? 0,
        statusEffectToApply: statusEffect,
        statusDuration:
            row[7] != null && row[7].toString().isNotEmpty && row[7] != 'null'
                ? int.tryParse(row[7].toString())
                : null,
        color: row[8] as String,
      );
      ownerCards.putIfAbsent(owner, () => []);
      ownerCards[owner]!.add(card);
    } catch (e) {
      GameLogger.warning(
          LogCategory.data, 'Error parsing card row: $row, error: $e');
      continue;
    }
  }
  return ownerCards;
}
