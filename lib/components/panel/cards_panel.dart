import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';

class CardsPanel extends BasePanel {
  final TextComponent cardAreaText;
  final TextComponent gameInfoText;
  final TextComponent turnText;
  final PlayerBase player;

  // Card layout constants
  static const double cardWidth = 140.0;
  static const double cardHeight = 180.0;
  static const double cardSpacing = 20.0; // Add some spacing between cards
  static const double cardTopMargin = 20.0;
  static const int maxCards = 5; // Allow more cards to be displayed

  CardsPanel({
    required this.player,
  }) : 
    cardAreaText = TextComponent(
      text: 'Your Hand',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    ),
    gameInfoText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    ),
    turnText = TextComponent(
      text: 'Turn: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      position: Vector2(0, 0), // Will be set in onLoad
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set text positions based on panel size
    cardAreaText.position = Vector2(20, 20);
    gameInfoText.position = Vector2(20, size.y - 40);
    turnText.position = Vector2(size.x - 100, 20);

    // Add text components
    add(cardAreaText);
    add(gameInfoText);
    add(turnText);
  }

  void updateGameInfo(String info) {
    gameInfoText.text = info;
  }

  void updateTurn(int turn) {
    turnText.text = 'Turn: $turn';
  }

  Vector2 calculateCardPosition(int index) {
    final totalWidth = (maxCards * cardWidth) + ((maxCards - 1) * cardSpacing);
    final startX = (size.x - totalWidth) / 2;

    final pos = Vector2(
      startX + (index * (cardWidth + cardSpacing)),
      cardTopMargin,
    );

    return pos;
  }

  @override
  void updateUI() {
    // Update any UI elements that need to be refreshed
    // This could include updating card positions, turn information, etc.
  }
} 