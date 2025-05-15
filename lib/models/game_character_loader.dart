import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_character.dart';
import 'game_card.dart';

Future<List<GameCard>> loadAllCards(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final header = rows.first;
  final dataRows = rows.skip(1);
  return dataRows.map((row) {
    return GameCard(
      name: row[0] as String,
      description: row[1] as String,
      type: CardType.values.firstWhere((e) => e.toString().split('.').last == row[2]),
      value: int.parse(row[3].toString()),
      cost: row.length > 4 && row[4] != null && row[4].toString().isNotEmpty ? int.parse(row[4].toString()) : 1,
      statusEffectToApply: row.length > 5 && row[5] != null && row[5].toString().isNotEmpty ? StatusEffect.values.firstWhere((e) => e.toString().split('.').last == row[5]) : null,
      statusDuration: row.length > 6 && row[6] != null && row[6].toString().isNotEmpty ? int.parse(row[6].toString()) : null,
      color: row.length > 7 && row[7] != null && row[7].toString().isNotEmpty ? row[7] as String : 'blue',
    );
  }).toList();
}

Future<Map<String, List<GameCard>>> loadDecks(String assetPath, List<GameCard> allCards) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);
  final Map<String, List<GameCard>> decks = {};
  for (final row in dataRows) {
    final owner = row[0] as String;
    final cardName = row[1] as String;
    final count = int.parse(row[2].toString());
    final card = allCards.firstWhere((c) => c.name == cardName);
    decks.putIfAbsent(owner, () => []);
    decks[owner]!.addAll(List.generate(count, (_) => card));
  }
  return decks;
}

Future<List<GameCharacter>> loadCharactersFromCsv(String assetPath, Map<String, List<GameCard>> decks, {bool isEnemy = false}) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final header = rows.first;
  final dataRows = rows.skip(1);
  return dataRows.map((row) {
    final name = row[0] as String;
    return GameCharacter(
      name: name,
      maxHealth: int.parse(row[1].toString()),
      attack: int.parse(row[2].toString()),
      defense: int.parse(row[3].toString()),
      emoji: row[4] as String,
      color: row[5] as String,
      imagePath: isEnemy ? row[6] as String : '',
      soundPath: isEnemy ? row[7] as String : '',
      description: isEnemy ? row[8] as String : row[6] as String,
      deck: decks[name] ?? [],
    );
  }).toList();
} 