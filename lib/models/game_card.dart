import 'package:card_combat_app/models/game_character.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:card_combat_app/utils/game_logger.dart';

enum CardType {
  attack,
  heal,
  statusEffect,
  cure,
  shield, // Adds shield to the player
  shieldAttack, // Attacks using shield value
}

class GameCard {
  final String name;
  final String description;
  final CardType type;
  final int value;
  final int cost;
  final StatusEffect? statusEffectToApply;
  final int? statusDuration;
  final String color;
  final String target; // 'player' or 'enemy' (or 'self')

  const GameCard({
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.cost,
    this.statusEffectToApply,
    this.statusDuration,
    this.color = "blue",
    this.target = "enemy", // default for player cards
  });

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type.toString().split('.').last,
        'value': value,
        'cost': cost,
        'statusEffectToApply': statusEffectToApply?.toString().split('.').last,
        'statusDuration': statusDuration,
        'color': color,
        'target': target,
      };

  static GameCard fromJson(Map<String, dynamic> json) => GameCard(
        name: json['name'],
        description: json['description'],
        type: CardType.values
            .firstWhere((e) => e.toString().split('.').last == json['type']),
        value: json['value'],
        cost: json['cost'],
        statusEffectToApply: json['statusEffectToApply'] != null &&
                json['statusEffectToApply'] != ''
            ? StatusEffect.values.firstWhere((e) =>
                e.toString().split('.').last == json['statusEffectToApply'])
            : null,
        statusDuration: json['statusDuration'],
        color: json['color'] ?? 'blue',
        target: json['target'] ?? 'enemy',
      );

  static Map<String, GameCard>? _allCards;

  /// Public getter for all loaded cards
  static List<GameCard> get allCards => _allCards?.values.toList() ?? [];

  /// Loads the card library from CSV and stores it internally
  static Future<void> loadLibrary(String assetPath) async {
    _allCards = await GameCard.loadCardsByNameFromCsv(assetPath);
  }

  /// Finds a card by name from the loaded library
  static GameCard? findByName(String name) {
    return _allCards != null ? _allCards![name] : null;
  }

  static Future<Map<String, List<GameCard>>> loadCardsByOwnerFromCsv(
      String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final rows =
        const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
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
              final description = row[2].toString().toLowerCase();
              if (description.contains('draw') &&
                  description.contains('energy')) {
                cardType = CardType.attack;
              } else if (description.contains('shield') ||
                  description.contains('block')) {
                cardType = CardType.shield;
              } else if (description.contains('heal') ||
                  description.contains('restore')) {
                cardType = CardType.heal;
              } else {
                cardType = CardType.attack;
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
        if (row[6] != null &&
            row[6].toString().isNotEmpty &&
            row[6] != 'null') {
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
    return ownerCards;
  }

  static Future<Map<String, GameCard>> loadCardsByNameFromCsv(
      String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final rows =
        const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
    final dataRows = rows.skip(1);
    final Map<String, GameCard> cardsByName = {};
    for (final row in dataRows) {
      try {
        if (row.length < 9) {
          GameLogger.warning(
              LogCategory.data, 'Skipping malformed card row: $row');
          continue;
        }
        final name = row[1] as String;
        CardType cardType;
        final typeStr = row[3].toString().toLowerCase();
        try {
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
              final description = row[2].toString().toLowerCase();
              if (description.contains('draw') &&
                  description.contains('energy')) {
                cardType = CardType.attack;
              } else if (description.contains('shield') ||
                  description.contains('block')) {
                cardType = CardType.shield;
              } else if (description.contains('heal') ||
                  description.contains('restore')) {
                cardType = CardType.heal;
              } else {
                cardType = CardType.attack;
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
        if (row[6] != null &&
            row[6].toString().isNotEmpty &&
            row[6] != 'null') {
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
        cardsByName[name] = card;
      } catch (e) {
        GameLogger.warning(
            LogCategory.data, 'Error parsing card row: $row, error: $e');
        continue;
      }
    }
    return cardsByName;
  }
}
