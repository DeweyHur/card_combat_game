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
import 'package:card_combat_app/components/layout/character_selection_box.dart';
import 'base_scene.dart';
import 'combat_scene.dart';

class PlayerSelectionScene extends BaseScene {
  late TextComponent titleText;
  late List<CharacterSelectionBox> characterBoxes;

  PlayerSelectionScene() : super(
    backgroundColor: const Color(0xFF2C3E50),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loading...');

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

    final boxWidth = game.size.x * 0.8;  // Wider boxes for better readability
    final boxHeight = game.size.y * 0.15;  // Reduced height to fit better on screen
    final spacing = game.size.y * 0.015;  // Reduced spacing between boxes
    final startX = (game.size.x - boxWidth) / 2;  // Center horizontally
    final startY = game.size.y * 0.15;  // Start higher on screen

    for (var i = 0; i < characters.length; i++) {
      final y = startY + (i * (boxHeight + spacing));
      
      final box = CharacterSelectionBox(
        name: characters[i]['name'] as String,
        emoji: characters[i]['emoji'] as String,
        description: characters[i]['description'] as String,
        color: characters[i]['color'] as Color,
        size: Vector2(boxWidth, boxHeight),
        position: Vector2(startX, y),
        onSelected: () => _onCharacterSelected(i),
      );
      
      add(box);
      characterBoxes.add(box);
    }
    
    GameLogger.debug(LogCategory.game, 'PlayerSelectionScene loaded successfully');
  }

  void _onCharacterSelected(int index) {
    GameLogger.info(LogCategory.game, 'Character selected: $index');
    try {
      final player = _createPlayer(index);
      GameLogger.info(LogCategory.game, 'Player created: ${player.runtimeType}');
      
      // Create and register combat scene with selected player
      final combatScene = CombatScene(
        player: player,
        enemy: Goblin(),
      );
      GameLogger.info(LogCategory.game, 'Combat scene created');
      
      sceneController.registerScene('combat', combatScene);
      GameLogger.info(LogCategory.game, 'Combat scene registered');
      
      // Initialize card pool and go to combat
      (game as CardCombatGame).initializeCardPool();
      GameLogger.info(LogCategory.game, 'Card pool initialized');
      
      sceneController.go('combat');
      GameLogger.info(LogCategory.game, 'Transitioning to combat scene');
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.game, 'Error during character selection: $e\n$stackTrace');
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