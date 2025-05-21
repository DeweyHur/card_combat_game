import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
<<<<<<< HEAD
    MaterialApp(
      title: 'Card Combat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PressStart2P',
      ),
      home: Scaffold(
        body: GameWidget(
          game: CardCombatGame(),
        ),
      ),
=======
    GameWidget(
      game: CardCombatGame(),
>>>>>>> 2bd455da771eb965092902f27b938d15a3e2b2cc
    ),
  );
}
