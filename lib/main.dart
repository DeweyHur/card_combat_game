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
    GameWidget(
      game: CardCombatGame(),
    ),
  );
}
