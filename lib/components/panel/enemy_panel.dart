import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flame/game.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';

class EnemyPanel extends BasePanel with HasGameRef, AreaFillerMixin implements CombatWatcher {
  EnemyBase enemy;
  TextComponent? actionText;
  TextComponent? healthText;
  RectangleComponent? separatorLine;
  SpriteComponent? enemySprite;
  AudioPlayer? audioPlayer;
  bool _isLoaded = false;
  late final TextComponent nameText;
  late final StatsRow statsRow;

  EnemyPanel({
    required this.enemy,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add enemy name
    nameText = TextComponent(
      text: enemy.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    addToVerticalStack(nameText, 30);

    // Add enemy stats row
    statsRow = StatsRow(character: enemy);
    addToVerticalStack(statsRow, 40);

    // Add enemy sprite
    try {
      final image = await gameRef.images.load(enemy.imagePath);
      final sprite = Sprite(image);
      enemySprite = SpriteComponent(
        sprite: sprite,
        size: Vector2(200, 200),
      );
      addToVerticalStack(enemySprite!, 200);
      GameLogger.info(LogCategory.ui, 'Enemy sprite:');
      GameLogger.info(LogCategory.ui, '  - Size: ${enemySprite!.size.x}x${enemySprite!.size.y}');
      GameLogger.info(LogCategory.ui, '  - Absolute Position: ${enemySprite!.absolutePosition.x},${enemySprite!.absolutePosition.y}');
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
    );
    addToVerticalStack(actionText!, 20);

    healthText = TextComponent(
      text: 'Health: ${enemy.currentHealth}/${enemy.maxHealth}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    addToVerticalStack(healthText!, 20);

    // Add separator line
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    addToVerticalStack(separatorLine!, 2);

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
    if (!_isLoaded) return;
    updateHealth();
    statsRow.updateUI();
  }

  void updateEnemy(EnemyBase newEnemy) {
    enemy = newEnemy;
    nameText.text = enemy.name;
    statsRow.setCharacter(enemy);
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
    drawAreaFiller(
      canvas,
      enemy.color.withOpacity(0.3),
      borderColor: enemy.color,
      borderWidth: 2.0,
    );
  }

  void showEffectForCard(dynamic card, VoidCallback onComplete) {
    final effect = GameEffects.createCardEffect(
      card.type,
      Vector2(size.x / 2 - 50, size.y / 2 - 50), // Centered in enemy panel
      Vector2(100, 100),
      onComplete: onComplete,
    )..priority = 100;
    add(effect);
  }

  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == enemy) {
      if (event.type == CombatEventType.damage || event.type == CombatEventType.heal || event.type == CombatEventType.status) {
        showEffectForCard(event.card ?? event, () {
          updateHealth();
        });
      } else if (event.type == CombatEventType.cure) {
        updateHealth();
      }
    }
  }
} 