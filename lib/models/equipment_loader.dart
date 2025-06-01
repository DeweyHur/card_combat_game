import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class EquipmentData {
  final String name;
  final String description;
  final String rarity;
  final String type;
  final List<String> cards;

  EquipmentData({
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'rarity': rarity,
        'type': type,
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

  // Log all unique types found in the CSV
  final Set<String> uniqueTypes = {};

  for (final row in dataRows) {
    if (row.length < 5 || row[0] == null || row[0].toString().trim().isEmpty) {
      continue;
    }
    final name = row[0] as String;
    final description = row[1] as String;
    final rarity = row[2] as String;
    final type = row[3] as String;
    final cardsStr = row[4]?.toString() ?? '';
    final cards = cardsStr.isNotEmpty ? cardsStr.split('|') : <String>[];

    // Log each equipment's type
    GameLogger.info(
      LogCategory.game,
      '[EQUIP_LOADER] Loading equipment: $name, Type: $type',
    );

    uniqueTypes.add(type.toLowerCase());

    equipment[name] = EquipmentData(
      name: name,
      description: description,
      rarity: rarity,
      type: type,
      cards: cards,
    );
  }

  // Log all unique types found
  GameLogger.info(
    LogCategory.game,
    '[EQUIP_LOADER] All unique equipment types found: ${uniqueTypes.join(", ")}',
  );

  return equipment;
}
