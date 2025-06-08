import 'package:card_combat_app/models/enemy.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'package:card_combat_app/utils/audio_config.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/enemy_action.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_combat_app/managers/static_data_manager.dart';
import 'package:card_combat_app/models/card.dart';
import 'package:flame/components.dart';

class CardCombatGame extends FlameGame with TapDetector, HasCollisionDetection {
  final SoundManager _soundManager = SoundManager();
  late final SceneManager sceneManager;
  late final Map<String, List<CardRun>> enemyDecks;

  CardCombatGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame loading...');

    // Initialize static data first
    await StaticDataManager.initialize();
    GameLogger.info(LogCategory.game, 'Static data initialized');

    final prefs = await SharedPreferences.getInstance();
    List<PlayerRun> players = [];
    List<EnemyRun> enemies = [];
    String? selectedPlayerName;

    // Try to load players from local storage
    final playersJson = prefs.getString('players');
    if (playersJson != null) {
      final List<dynamic> decoded = jsonDecode(playersJson);
      for (final data in decoded) {
        final template =
            StaticDataManager.findPlayerTemplate(data['name'] as String);
        if (template != null) {
          final setup = PlayerSetup(template);
          final player = PlayerRun(setup);
          // Load equipment
          if (data['equipment'] != null) {
            final equipmentMap = Map<String, dynamic>.from(data['equipment']);
            equipmentMap.forEach((slot, eqData) {
              final eq = EquipmentTemplate.fromJson(eqData);
              player.equip(slot, eq);
            });
          }
          players.add(player);
        }
      }
    }
    // Try to load selected player from local storage
    selectedPlayerName = prefs.getString('selectedPlayerName');

    // If no players loaded, create them from templates
    if (players.isEmpty) {
      // Create players from templates
      for (final template in StaticDataManager.playerTemplates) {
        final setup = PlayerSetup(template);
        final player = PlayerRun(setup);
        players.add(player);
      }

      // Create enemies from templates
      for (final template in StaticDataManager.enemyTemplates) {
        final enemy = EnemyRun(template);
        enemies.add(enemy);
      }

      // Save to local storage
      prefs.setString(
          'players', jsonEncode(players.map((e) => e.toJson()).toList()));
    } else {
      // If loaded from local storage, still need to load enemies
      // Create enemies from templates
      for (final template in StaticDataManager.enemyTemplates) {
        final enemy = EnemyRun(template);
        enemies.add(enemy);
      }
    }

    // Load enemy actions and convert them to cards
    await EnemyActionTemplate.loadFromCsv('assets/data/enemy_actions.csv');
    enemyDecks = {};
    for (final template in EnemyActionTemplate.templates) {
      final actionRun = EnemyActionRun.fromTemplate(template, 'enemy');
      final card = actionRun.toCardRun();
      if (card != null) {
        enemyDecks.putIfAbsent(template.type, () => []).add(card);
      }
    }

    DataController.instance.set<List<GameCharacter>>('players', players);
    DataController.instance.set<List<GameCharacter>>('enemies', enemies);

    // Set selected player
    PlayerRun? selectedPlayer;
    if (selectedPlayerName != null) {
      final found = players.where((p) => p.name == selectedPlayerName);
      if (found.isNotEmpty) {
        selectedPlayer = found.first;
        // Load saved equipment for selected player
        final savedEquipment =
            prefs.getString('playerEquipment:${selectedPlayer.name}');
        if (savedEquipment != null) {
          try {
            final equipmentMap =
                Map<String, dynamic>.from(jsonDecode(savedEquipment));
            equipmentMap.forEach((slot, data) {
              final eq = EquipmentTemplate.fromJson(data);
              selectedPlayer?.equip(slot, eq);
            });
          } catch (e) {
            GameLogger.error(
                LogCategory.data, 'Error loading saved equipment: $e');
          }
        }
      }
    }
    if (selectedPlayer == null && players.isNotEmpty) {
      selectedPlayer = players.first;
      // Load saved equipment for first player
      final savedEquipment =
          prefs.getString('playerEquipment:${selectedPlayer.name}');
      if (savedEquipment != null) {
        try {
          final equipmentMap =
              Map<String, dynamic>.from(jsonDecode(savedEquipment));
          equipmentMap.forEach((slot, data) {
            final eq = EquipmentTemplate.fromJson(data);
            selectedPlayer?.equip(slot, eq);
          });
        } catch (e) {
          GameLogger.error(
              LogCategory.data, 'Error loading saved equipment: $e');
        }
      }
    }
    if (selectedPlayer != null) {
      DataController.instance
          .set<GameCharacter>('selectedPlayer', selectedPlayer);
      prefs.setString('selectedPlayerName', selectedPlayer.name);
      // Save the player's equipment to local storage
      prefs.setString('playerEquipment:${selectedPlayer.name}',
          jsonEncode(selectedPlayer.equipment));
    }

    // Initialize audio configuration
    await AudioConfig.initialize();
    GameLogger.info(LogCategory.audio, 'Audio configuration initialized');

    // Initialize sound system
    await _soundManager.initialize();
    GameLogger.info(LogCategory.audio, 'Sound system initialized');

    // Initialize scene manager and load initial scene
    sceneManager = SceneManager();
    sceneManager.initialize(this);

    // Start with main menu
    sceneManager.pushScene('title');
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.info(LogCategory.system, 'Game mounted');
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  void onRemove() {
    GameLogger.debug(
        LogCategory.system, 'Game being removed, cleaning up resources');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameLogger.debug(
        LogCategory.system, 'Game resized to: ${size.x}x${size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > 0.1) {
      GameLogger.warning(LogCategory.system, 'Game update with high dt: $dt');
    }
  }

  @override
  void render(Canvas canvas) {
    try {
      super.render(canvas);
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.system, 'Error in render: $e');
      GameLogger.debug(LogCategory.system, 'Stack trace: $stackTrace');
      rethrow;
    }
  }
}
