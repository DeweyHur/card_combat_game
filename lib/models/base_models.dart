import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'dart:math';

/// Base class for static data loaded from CSV files
abstract class StaticDataModel {
  static Future<List<List<dynamic>>> loadCsvData(String assetPath) async {
    try {
      final rawData = await rootBundle.loadString(assetPath);
      GameLogger.info(
          LogCategory.data, 'Raw CSV data length: ${rawData.length}');
      GameLogger.info(LogCategory.data,
          'Raw CSV data first 100 chars: ${rawData.substring(0, min(100, rawData.length))}');
      GameLogger.info(LogCategory.data,
          'Raw CSV data contains newlines: ${rawData.contains('\n')}');
      GameLogger.info(LogCategory.data,
          'Raw CSV data contains carriage returns: ${rawData.contains('\r')}');

      // Normalize all line endings to \n
      final normalized =
          rawData.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final lines = normalized
          .split('\n')
          .where(
              (line) => line.trim().isNotEmpty && !line.trim().startsWith('//'))
          .toList();
      final cleaned = lines.join('\n');
      GameLogger.info(LogCategory.data,
          'CLEANED CSV STRING (first 300 chars): ${cleaned.substring(0, min(300, cleaned.length))}');

      // Split the cleaned string into lines and process each line
      final csvLines = cleaned.split('\n');
      GameLogger.info(
          LogCategory.data, 'Number of lines after split: ${csvLines.length}');

      if (csvLines.isEmpty) {
        GameLogger.error(LogCategory.data, 'No lines found in CSV data');
        return [];
      }

      // First line should be headers
      final headers = csvLines[0].split(',');
      GameLogger.info(LogCategory.data, 'Headers: $headers');

      // Process data rows
      final dataRows = <List<String>>[];
      for (var i = 1; i < csvLines.length; i++) {
        final line = csvLines[i].trim();
        if (line.isEmpty) continue;

        // Split by comma but preserve pipe-separated values
        final row = <String>[];
        var currentValue = '';
        var inQuotes = false;

        for (var j = 0; j < line.length; j++) {
          final char = line[j];
          if (char == '"') {
            inQuotes = !inQuotes;
          } else if (char == ',' && !inQuotes) {
            row.add(currentValue.trim());
            currentValue = '';
          } else {
            currentValue += char;
          }
        }
        row.add(currentValue.trim()); // Add the last value

        if (row.length >= headers.length) {
          dataRows.add(row);
          if (i <= 3) {
            // Log first 3 data rows
            GameLogger.info(LogCategory.data, 'Data row $i: $row');
          }
        } else {
          GameLogger.warning(
              LogCategory.data, 'Skipping malformed row $i: $row');
        }
      }

      GameLogger.info(
          LogCategory.data, 'Processed ${dataRows.length} valid data rows');
      return dataRows;
    } catch (e) {
      GameLogger.error(LogCategory.data, 'Error loading CSV data: ${e}');
      return [];
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
