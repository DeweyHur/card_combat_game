import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/utils/game_logger.dart';

/// Base class for static data loaded from CSV files
abstract class StaticDataModel {
  static Future<List<List<dynamic>>> loadCsvData(String assetPath) async {
    try {
      final rawData = await rootBundle.loadString(assetPath);
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(rawData);
      return rows.skip(1).toList(); // Skip header row
    } catch (e) {
      GameLogger.error(
          LogCategory.data, 'Error loading CSV data from $assetPath: $e');
      rethrow;
    }
  }

  /// Generic find method to search templates by any field
  static T? find<T>(List<T>? templates, String field, dynamic value) {
    if (templates == null) return null;

    try {
      return templates.firstWhere(
        (template) {
          final fieldValue = (template as dynamic).$field;
          return fieldValue == value;
        },
        orElse: () => throw Exception('Template not found: $field = $value'),
      );
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error finding template: $e');
      return null;
    }
  }
}

/// Base class for local setup data that can be saved/loaded
abstract class LocalSetupModel {
  Future<void> saveToLocalStorage();
  Future<void> loadFromLocalStorage();
}

/// Base class for run data that can be saved/loaded
abstract class RunDataModel {
  Future<void> saveRunData();
  Future<void> loadRunData();
}
