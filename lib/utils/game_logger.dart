import 'package:flutter/foundation.dart';

const bool kDebugMode = true;

enum LogCategory { system, game, ui, data, audio, effect, model, combat, debug }

class GameLogger {
  static void debug(LogCategory category, String message) {
    if (kDebugMode) {
      debugPrint('[[36m${category.name.toUpperCase()}[0m] $message');
    }
  }

  static void info(LogCategory category, String message) {
    if (kDebugMode) {
      debugPrint('[[32m${category.name.toUpperCase()}[0m] INFO: $message');
    }
  }

  static void warning(LogCategory category, String message) {
    if (kDebugMode) {
      debugPrint('[[33m${category.name.toUpperCase()}[0m] WARNING: $message');
    }
  }

  static void error(LogCategory category, String message) {
    if (kDebugMode) {
      debugPrint('[[31m${category.name.toUpperCase()}[0m] ERROR: $message');
    }
  }
}
