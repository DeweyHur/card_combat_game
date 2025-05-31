import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class EquipmentData {
  final String name;
  final String type;
  final String slot;
  final String handedness;
  final List<String> cards;

  EquipmentData({
    required this.name,
    required this.type,
    required this.slot,
    required this.handedness,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'slot': slot,
        'handedness': handedness,
        'cards': cards,
      };
}

Future<Map<String, EquipmentData>> loadEquipmentFromCsv(
    String assetPath) async {
  final csvString = await rootBundle.loadString(assetPath);
  final rows =
      const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
  final dataRows = rows.skip(1);
  final Map<String, EquipmentData> equipment = {};
  for (final row in dataRows) {
    if (row.length < 5 || row[0] == null || row[0].toString().trim().isEmpty) {
      continue;
    }
    final name = row[0] as String;
    final type = row[1] as String;
    final rarity = row[2] as String;
    final slot = row[3] as String;
    final cardsStr = row[4]?.toString() ?? '';
    final cards = cardsStr.isNotEmpty ? cardsStr.split('|') : <String>[];
    equipment[name] = EquipmentData(
      name: name,
      type: type,
      slot: slot,
      handedness: rarity,
      cards: cards,
    );
  }
  return equipment;
}
