import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/card_combat_game.dart'; // We'll create this file next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Combat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'monospace',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: CardCombatGame(),
        loadingBuilder: (context) => const Center(
          child: Text(
            'Loading...',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
            ),
          ),
        ),
        errorBuilder: (context, error) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
