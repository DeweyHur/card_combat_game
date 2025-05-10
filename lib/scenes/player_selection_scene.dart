import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/card_combat_game.dart';
import '../models/game_card.dart';
import '../models/characters/fighter.dart';
import '../models/characters/paladin.dart';
import '../models/characters/sorcerer.dart';
import '../models/characters/warlock.dart';
import '../models/characters/player_base.dart';
import '../utils/game_logger.dart';
import 'base_scene.dart';
import 'combat_scene.dart';

class PlayerSelectionScene extends BaseScene with TapCallbacks {
  late TextComponent titleText;
  late List<RectangleComponent> characterBoxes;
  late List<TextComponent> characterNames;
  late List<TextComponent> characterDescriptions;
  late List<TextComponent> characterEmojis;

  PlayerSelectionScene(CardCombatGame game) : super(
    game: game,
    backgroundColor: const Color(0xFF2C3E50),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add title
    titleText = TextComponent(
      text: 'Choose Your Character',
      position: Vector2(game.size.x / 2, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(titleText);

    // Create character selection boxes
    final characters = [
      {
        'name': 'Fighter',
        'emoji': '⚔️',
        'description': 'High HP, +1 energy per turn\nAttack cards deal +1 damage',
        'color': const Color(0xFF3498DB),
      },
      {
        'name': 'Paladin',
        'emoji': '🛡️',
        'description': 'Highest HP, heals 2 HP per turn\nHealing cards heal +2 HP',
        'color': const Color(0xFFF1C40F),
      },
      {
        'name': 'Sorcerer',
        'emoji': '🧙',
        'description': 'Low HP, draws extra card\nStatus effects last longer',
        'color': const Color(0xFF9B59B6),
      },
      {
        'name': 'Warlock',
        'emoji': '👻',
        'description': 'Medium HP, more energy\nPowerful attacks with drawbacks',
        'color': const Color(0xFF2C3E50),
      },
    ];

    characterBoxes = [];
    characterNames = [];
    characterDescriptions = [];
    characterEmojis = [];

    final boxWidth = game.size.x * 0.4;
    final boxHeight = game.size.y * 0.6;
    final spacing = game.size.x * 0.05;
    final startX = (game.size.x - (boxWidth * 2 + spacing)) / 2;
    final startY = game.size.y * 0.2;

    for (var i = 0; i < characters.length; i++) {
      final row = i ~/ 2;
      final col = i % 2;
      final x = startX + (col * (boxWidth + spacing));
      final y = startY + (row * (boxHeight + spacing));

      // Create character box
      final box = RectangleComponent(
        position: Vector2(x, y),
        size: Vector2(boxWidth, boxHeight),
        paint: Paint()..color = characters[i]['color'] as Color,
      );
      add(box);
      characterBoxes.add(box);

      // Add character emoji
      final emoji = TextComponent(
        text: characters[i]['emoji'] as String,
        position: Vector2(x + boxWidth / 2, y + 60),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 48,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.center,
      );
      add(emoji);
      characterEmojis.add(emoji);

      // Add character name
      final name = TextComponent(
        text: characters[i]['name'] as String,
        position: Vector2(x + boxWidth / 2, y + 120),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.center,
      );
      add(name);
      characterNames.add(name);

      // Add character description
      final description = TextComponent(
        text: characters[i]['description'] as String,
        position: Vector2(x + boxWidth / 2, y + 180),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.center,
      );
      add(description);
      characterDescriptions.add(description);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final tapPosition = event.canvasPosition;

    for (var i = 0; i < characterBoxes.length; i++) {
      if (characterBoxes[i].containsPoint(tapPosition)) {
        _onCharacterSelected(i);
        break;
      }
    }
  }

  void _onCharacterSelected(int index) {
    GameLogger.info(LogCategory.game, 'Character selected: $index');
    final player = _createPlayer(index);
    if (player != null) {
      (game as CardCombatGame).initializeCardPool();
      sceneController.go('combat', params: {'player': player});
    }
  }

  PlayerBase _createPlayer(int index) {
    switch (index) {
      case 0:
        return Fighter();
      case 1:
        return Paladin();
      case 2:
        return Sorcerer();
      case 3:
        return Warlock();
      default:
        throw Exception('Invalid player index: $index');
    }
  }
} 