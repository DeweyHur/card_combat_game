import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/card_combat_game.dart'; // We'll create this file next

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark blue background
      ),
      home: Scaffold(
        body: SafeArea(
          child: GameWidget(
            game: CardCombatGame(),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
