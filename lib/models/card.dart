import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class Card {
  final String owner;
  final String name;
  final String description;
  final String type;
  int value;
  int cost;
  final String? statusEffect;
  final int? statusDuration;
  final String color;
  int level;

  Card({
    required this.owner,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.cost,
    this.statusEffect,
    this.statusDuration,
    required this.color,
    this.level = 1,
  });

  void upgrade() {
    level++;
    value = (value * 1.5).round();
    if (cost > 0) {
      cost = (cost * 0.8).round().clamp(0, 3);
    }
  }

  static Future<Card> getCardByName(String name) async {
    final String rawData = await rootBundle.loadString('assets/data/cards.csv');
    final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

    // Skip header row
    final List<List<dynamic>> data = listData.skip(1).toList();

    for (var row in data) {
      if (row[1].toString() == name) {
        return Card(
          owner: row[0].toString(),
          name: row[1].toString(),
          description: row[2].toString(),
          type: row[3].toString(),
          value: int.parse(row[4].toString()),
          cost: int.parse(row[5].toString()),
          statusEffect: row[6].toString().isEmpty ? null : row[6].toString(),
          statusDuration:
              row[7].toString().isEmpty ? null : int.parse(row[7].toString()),
          color: row[8].toString(),
        );
      }
    }

    throw Exception('Card not found: $name');
  }

  static Card fromString(String data) {
    final parts = data.split(':');
    if (parts.length < 4) {
      throw Exception('Invalid card data format: $data');
    }

    // Map the card type to a valid value
    String cardType = parts[2];
    switch (cardType) {
      case 'defense':
        cardType = 'shield';
        break;
      case 'skill':
        cardType = 'attack';
        break;
      // Add more mappings if needed
    }

    return Card(
      name: parts[0],
      description: parts[1],
      type: cardType,
      value: int.parse(parts[3]),
      cost: parts.length > 4 ? int.parse(parts[4]) : 0,
      owner: parts.length > 5 ? parts[5] : 'player',
      color: parts.length > 6 ? parts[6] : 'blue',
    );
  }

  @override
  String toString() => '$name (Level $level) - $value $type, $cost energy';
}
