import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flame/game.dart';

class EnemyPanel extends BasePanel with HasGameRef {
  EnemyBase enemy;
  TextComponent? actionText;
  TextComponent? healthText;
  RectangleComponent? separatorLine;
  SpriteComponent? enemySprite;
  AudioPlayer? audioPlayer;
  bool _isLoaded = false;
  late final TextComponent nameText;
  late final TextComponent statsText;

  EnemyPanel({
    required this.enemy,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'EnemyPanel loading...');

    // Set size and position
    size = Vector2(300, 400);

    // Add enemy name
    nameText = TextComponent(
      text: enemy.name,
      position: Vector2(size.x / 2, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    // Add enemy stats
    statsText = TextComponent(
      text: 'HP: ${enemy.maxHealth}\nATK: ${enemy.attack}\nDEF: ${enemy.defense}',
      position: Vector2(size.x / 2, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(statsText);

    // Add enemy sprite
    try {
      final image = await gameRef.images.load(enemy.imagePath);
      final sprite = Sprite(image);
      enemySprite = SpriteComponent(
        sprite: sprite,
        position: Vector2(size.x / 2, size.y / 2),
        size: Vector2(200, 200),
        anchor: Anchor.center,
      );
      add(enemySprite!);
    } catch (e) {
      GameLogger.error(LogCategory.ui, 'Failed to load enemy sprite: $e');
    }

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
    GameLogger.debug(LogCategory.ui, 'EnemyPanel loaded successfully');
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

  void updateEnemy(EnemyBase newEnemy) {
    enemy = newEnemy;
    nameText.text = enemy.name;
    statsText.text = 'HP: ${enemy.maxHealth}\nATK: ${enemy.attack}\nDEF: ${enemy.defense}';
    // TODO: Update sprite when enemy changes
  }

  @override
  void onRemove() {
    audioPlayer?.stop();
    audioPlayer?.dispose();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw panel background
    final paint = Paint()
      ..color = enemy.color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = enemy.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }
} 