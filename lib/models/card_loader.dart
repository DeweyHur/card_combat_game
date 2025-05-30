import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CardLoaderResult {
  final Map<String, List<GameCard>> ownerCards;
  final Map<String, GameCard> cardsByName;

  CardLoaderResult({
    required this.ownerCards,
    required this.cardsByName,
  });
}

/// Loads all cards from CSV and returns both owner-based and name-based maps
Future<CardLoaderResult> loadCardsByOwnerFromCsv(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');

  // Assume header: owner,name,description,type,value,cost,statusEffect,statusDuration,color
  final dataRows = rows.skip(1);

  final Map<String, List<GameCard>> ownerCards = {};
  final Map<String, GameCard> cardsByName = {};

  for (final row in dataRows) {
    try {
      if (row.length < 9) {
        GameLogger.warning(
            LogCategory.data, 'Skipping malformed card row: $row');
        continue;
      }
      final owner = row[0] as String;
      final name = row[1] as String;
      CardType cardType;
      final typeStr = row[3].toString().toLowerCase();
      try {
        // Map card types to enum values
        switch (typeStr) {
          case 'attack':
            cardType = CardType.attack;
            break;
          case 'defense':
          case 'shield':
            cardType = CardType.shield;
            break;
          case 'heal':
            cardType = CardType.heal;
            break;
          case 'skill':
            // Map skill cards to appropriate types based on their effect
            final description = row[2].toString().toLowerCase();
            if (description.contains('draw') &&
                description.contains('energy')) {
              cardType = CardType
                  .attack; // Map to attack since it's an offensive skill
            } else if (description.contains('shield') ||
                description.contains('block')) {
              cardType = CardType.shield;
            } else if (description.contains('heal') ||
                description.contains('restore')) {
              cardType = CardType.heal;
            } else {
              cardType = CardType.attack; // Default to attack for other skills
            }
            break;
          case 'cure':
            cardType = CardType.cure;
            break;
          default:
            GameLogger.warning(LogCategory.data,
                'Unknown card type: \'$typeStr\' in row: $row');
            continue;
        }
      } catch (e) {
        GameLogger.warning(LogCategory.data,
            'Error mapping card type: \'$typeStr\' in row: $row');
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
        name: name,
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
      cardsByName[name] = card;
    } catch (e) {
      GameLogger.warning(
          LogCategory.data, 'Error parsing card row: $row, error: $e');
      continue;
    }
  }
  return CardLoaderResult(ownerCards: ownerCards, cardsByName: cardsByName);
}
