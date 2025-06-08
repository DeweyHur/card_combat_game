import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/models/card.dart';

/// This loader is now only used for enemy decks, as player decks are built from equipment.
/// You may remove this file if you migrate enemy decks to a new system.

/// Loads player decks from a long-format CSV (player,card,count), matching card names to loaded CardRun objects.
Future<Map<String, List<CardRun>>> loadPlayerDecksFromCsv(
    String assetPath, List<CardRun> allCards) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');

  // Skip header
  final dataRows = rows.skip(1);
  final Map<String, List<CardRun>> playerDecks = {};

  for (final row in dataRows) {
    final player = row[0] as String;
    final cardName = row[1] as String;
    final count = int.parse(row[2].toString());
    final card = allCards.firstWhere((c) => c.name == cardName);
    playerDecks.putIfAbsent(player, () => []);
    playerDecks[player]!.addAll(List.generate(count, (_) => card));
  }

  return playerDecks;
}
