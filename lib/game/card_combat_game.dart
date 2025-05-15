import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/managers/sound_manager.dart';
import 'package:card_combat_app/utils/audio_config.dart';

class CardCombatGame extends FlameGame with TapDetector, HasCollisionDetection {
  final SoundManager _soundManager = SoundManager();

  CardCombatGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame loading...');

    // Initialize audio configuration
    await AudioConfig.initialize();
    GameLogger.info(LogCategory.audio, 'Audio configuration initialized');

    // Initialize sound system
    await _soundManager.initialize();
    GameLogger.info(LogCategory.audio, 'Sound system initialized');

    // Initialize scene manager and load initial scene
    SceneManager().initialize(this);
    SceneManager().pushScene('player_selection');
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
    GameLogger.debug(LogCategory.system, 'Game being removed, cleaning up resources');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameLogger.debug(LogCategory.system, 'Game resized to: ${size.x}x${size.y}');
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