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
    ),
  );
}
