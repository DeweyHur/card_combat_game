import 'package:flutter/foundation.dart';

enum LogCategory {
  system,
  game,
  ui,
  audio,
  effect,
  model,
  combat,
  debug
}

class GameLogger {
  static void debug(LogCategory category, String message) {
    if (kDebugMode) {
      print('[${category.name.toUpperCase()}] $message');
    }
  }

  static void info(LogCategory category, String message) {
    if (kDebugMode) {
      print('[${category.name.toUpperCase()}] INFO: $message');
    }
  }

  static void warning(LogCategory category, String message) {
    if (kDebugMode) {
      print('[${category.name.toUpperCase()}] WARNING: $message');
    }
  }

  static void error(LogCategory category, String message) {
    if (kDebugMode) {
      print('[${category.name.toUpperCase()}] ERROR: $message');
    }
  }
} 