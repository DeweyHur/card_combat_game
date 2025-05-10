import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/card_combat_game.dart';
import 'utils/game_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  GameLogger.info(LogCategory.system, '=== APP STARTING ===');
  GameLogger.debug(LogCategory.system, 'Testing debug log');
  GameLogger.warning(LogCategory.system, 'Testing warning log');
  GameLogger.error(LogCategory.system, 'Testing error log');

  runApp(
    MaterialApp(
      title: 'Card Combat Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: GameWidget(
          game: CardCombatGame(),
          loadingBuilder: (context) => const Center(
            child: Text(
              'Loading...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          errorBuilder: (context, error) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
