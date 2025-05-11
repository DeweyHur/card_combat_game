import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/card_combat_game.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          game: CardCombatGame(),
        ),
      ),
    ),
  );
}
