import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'card.dart';

class Equipment {
  final String name;
  final String description;
  final String rarity;
  final String type;
  final List<Card> cards;
  final String slot;

  Equipment({
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    required this.cards,
    required this.slot,
  });

  static Equipment fromString(String data) {
    final parts = data.split(':');
    if (parts.length < 5) {
      throw Exception('Invalid equipment data format: $data');
    }

    // Parse cards string into list of Card objects
    List<Card> cards = [];
    if (parts[4].isNotEmpty) {
      final cardStrings = parts[4].split('|');
      for (var cardString in cardStrings) {
        final cardParts = cardString.split(':');
        if (cardParts.length >= 4) {
          cards.add(Card(
            name: cardParts[0],
            description: cardParts[1],
            type: 'attack', // Default type
            value: int.parse(cardParts[2]),
            cost: int.parse(cardParts[3]),
            owner: 'player', // Default owner
            color: 'blue', // Default color
          ));
        }
      }
    }

    return Equipment(
      name: parts[0],
      description: parts[1],
      rarity: parts[2],
      type: parts[3],
      cards: cards,
      slot: parts[3].toLowerCase(), // Use type as slot
    );
  }

  static Future<Equipment> loadFromCSV(String name) async {
    final String rawData =
        await rootBundle.loadString('assets/data/equipment.csv');
    final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

    // Skip header row
    final List<List<dynamic>> data = listData.skip(1).toList();

    for (var row in data) {
      if (row[0].toString() == name) {
        // Parse cards string into list of Card objects
        List<Card> cards = [];
        if (row[4].toString().isNotEmpty) {
          final cardStrings = row[4].toString().split('|');
          for (var cardString in cardStrings) {
            final parts = cardString.split(':');
            if (parts.length >= 4) {
              cards.add(Card(
                name: parts[0],
                description: parts[1],
                type: 'attack', // Default type
                value: int.parse(parts[2]),
                cost: int.parse(parts[3]),
                owner: 'player', // Default owner
                color: 'blue', // Default color
              ));
            }
          }
        }

        return Equipment(
          name: row[0].toString(),
          description: row[1].toString(),
          rarity: row[2].toString(),
          type: row[3].toString(),
          cards: cards,
          slot: row[3].toString().toLowerCase(), // Use type as slot
        );
      }
    }

    throw Exception('Equipment not found: $name');
  }
}
