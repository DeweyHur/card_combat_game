import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_character.dart';
import 'game_card.dart';
import 'equipment_loader.dart';

Future<List<GameCard>> loadAllCards(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);
  return dataRows.map((row) {
    return GameCard(
      name: row[0] as String,
      description: row[1] as String,
      type: CardType.values
          .firstWhere((e) => e.toString().split('.').last == row[2]),
      value: int.parse(row[3].toString()),
      cost: row.length > 4 && row[4] != null && row[4].toString().isNotEmpty
          ? int.parse(row[4].toString())
          : 1,
      statusEffectToApply:
          row.length > 5 && row[5] != null && row[5].toString().isNotEmpty
              ? StatusEffect.values
                  .firstWhere((e) => e.toString().split('.').last == row[5])
              : null,
      statusDuration:
          row.length > 6 && row[6] != null && row[6].toString().isNotEmpty
              ? int.parse(row[6].toString())
              : null,
      color: row.length > 7 && row[7] != null && row[7].toString().isNotEmpty
          ? row[7] as String
          : 'blue',
    );
  }).toList();
}

Future<List<GameCharacter>> loadCharactersFromCsv(String assetPath,
    List<GameCard> allCards, Map<String, EquipmentData> equipmentData,
    {bool isEnemy = false}) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);
  return dataRows.map((row) {
    final name = row[0] as String;
    final equipmentStr = row.length > 10 ? row[10] as String : '';
    final equipmentList = equipmentStr
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    // Build deck from equipment
    final List<String> cardNames = [];
    for (final eqName in equipmentList) {
      final eq = equipmentData[eqName];
      if (eq != null) {
        cardNames.addAll(eq.cards);
      }
    }
    // Map card names to GameCard instances
    final List<GameCard> deck = [];
    for (final cardName in cardNames) {
      final cardIndex = allCards.indexWhere((c) => c.name == cardName);
      if (cardIndex != -1) deck.add(allCards[cardIndex]);
    }
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
      deck: deck,
      maxEnergy: 3,
      handSize: isEnemy ? 5 : int.parse(row[8].toString()),
    );
  }).toList();
}

Future<List<GameCharacter>> loadEnemiesFromCsv(
  String assetPath,
  Map<String, List<GameCard>> enemyDecks,
) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
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
      imagePath: row[6] as String,
      soundPath: row[7] as String,
      description: row[8] as String,
      deck: enemyDecks[name] ?? [],
      maxEnergy: 3,
      handSize: 5,
    );
  }).toList();
}
