import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class CardCombatGame extends FlameGame with TapDetector, HasCollisionDetection {
  final bool _audioEnabled = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  CardCombatGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame loading...');

    // Initialize scene manager and load initial scene
    SceneManager().initialize(this);
    SceneManager().pushScene('player_selection');
  }

  Future<bool> _initializeAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
      GameLogger.info(LogCategory.audio, 'Audio player initialized successfully');
      return true;
    } catch (e) {
      GameLogger.error(LogCategory.audio, 'Failed to initialize audio: $e');
      return false;
    }
  }

  Future<void> playCardSound() async {
    if (_audioEnabled) {
      try {
        await _audioPlayer.play(AssetSource('sounds/card_play.mp3'));
      } catch (e) {
        GameLogger.error(LogCategory.audio, 'Failed to play card sound: $e');
      }
    }
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
    _audioPlayer.dispose();
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