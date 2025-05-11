import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';

class EnemyPanel extends BasePanel with HasGameRef {
  final EnemyBase enemy;
  TextComponent? actionText;
  TextComponent? healthText;
  RectangleComponent? separatorLine;
  SpriteComponent? enemySprite;
  AudioPlayer? audioPlayer;
  bool _isLoaded = false;

  EnemyPanel({
    required this.enemy,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load enemy sprite
    final sprite = await gameRef.loadSprite(enemy.imagePath);
    enemySprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(80, 80),
      position: Vector2(10, 10),
    );
    add(enemySprite!);

    // Load enemy sound
    try {
      audioPlayer = AudioPlayer();
      await audioPlayer?.setSource(AssetSource(enemy.soundPath));
      await audioPlayer?.setVolume(0.3); // Set volume to 30%
      await audioPlayer?.resume(); // Start playing
    } catch (e) {
      GameLogger.warning(LogCategory.audio, 'Failed to load enemy sound: $e');
    }

    // Create text components
    actionText = TextComponent(
      text: 'Next Action: None',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(100, 20),
    );
    add(actionText!);

    healthText = TextComponent(
      text: 'Health: ${enemy.currentHealth}/${enemy.maxHealth}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      position: Vector2(100, 50),
    );
    add(healthText!);

    // Add separator line
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      position: Vector2(10, 90),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    add(separatorLine!);

    _isLoaded = true;
  }

  void updateAction(String action) {
    if (_isLoaded && actionText != null) {
      actionText!.text = 'Next Action: $action';
    }
  }

  void updateHealth() {
    if (_isLoaded && healthText != null) {
      healthText!.text = 'Health: ${enemy.currentHealth}/${enemy.maxHealth}';
    }
  }

  @override
  void updateUI() {
    updateHealth();
  }

  @override
  void onRemove() {
    audioPlayer?.stop();
    audioPlayer?.dispose();
    super.onRemove();
  }
} 