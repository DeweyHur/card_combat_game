import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/goblin.dart';
import 'package:card_combat_app/utils/game_logger.dart';
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

    final boxWidth = game.size.x * 0.8;  // Wider boxes for better readability
    final boxHeight = game.size.y * 0.15;  // Reduced height to fit better on screen
    final spacing = game.size.y * 0.015;  // Reduced spacing between boxes
    final startX = (game.size.x - boxWidth) / 2;  // Center horizontally
    final startY = game.size.y * 0.15;  // Start higher on screen

    for (var i = 0; i < characters.length; i++) {
      final y = startY + (i * (boxHeight + spacing));

      // Create character box
      final box = RectangleComponent(
        position: Vector2(startX, y),
        size: Vector2(boxWidth, boxHeight),
        paint: Paint()..color = characters[i]['color'] as Color,
      );
      add(box);
      characterBoxes.add(box);

      // Add character emoji
      final emoji = TextComponent(
        text: characters[i]['emoji'] as String,
        position: Vector2(startX + 50, y + boxHeight * 0.35),  // Adjusted position
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32,  // Slightly smaller emoji
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
        position: Vector2(startX + 120, y + boxHeight * 0.35),  // Aligned with emoji
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 22,  // Slightly smaller text
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.centerLeft,
      );
      add(name);
      characterNames.add(name);

      // Add character description
      final description = TextComponent(
        text: characters[i]['description'] as String,
        position: Vector2(startX + 50, y + boxHeight * 0.75),  // Adjusted position
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 14,  // Slightly smaller text
            color: Colors.white,
          ),
        ),
        anchor: Anchor.topLeft,
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
      // Create and register combat scene with selected player
      final combatScene = CombatScene(
        game: game as CardCombatGame,
        player: player,
        enemy: Goblin(),
      );
      sceneController.registerScene('combat', combatScene);
      
      // Initialize card pool and go to combat
      (game as CardCombatGame).initializeCardPool();
      sceneController.go('combat');
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