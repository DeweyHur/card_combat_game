import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class EnemyData {
  final String name;
  final int maxHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  final String imagePath;
  final String soundPath;
  final String description;
  final String special;

  EnemyData({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.soundPath,
    required this.description,
    required this.special,
  });
}

Future<List<EnemyData>> loadEnemiesFromCsv(String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows = const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);

  return dataRows.map((row) {
    return EnemyData(
      name: row[0] as String,
      maxHealth: int.parse(row[1].toString()),
      attack: int.parse(row[2].toString()),
      defense: int.parse(row[3].toString()),
      emoji: row[4] as String,
      color: row[5] as String,
      imagePath: row[6] as String,
      soundPath: row[7] as String,
      description: row[8] as String,
      special: row[9] as String,
    );
  }).toList();
} 