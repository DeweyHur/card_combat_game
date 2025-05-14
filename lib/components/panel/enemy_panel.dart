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
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/action_with_emoji_component.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';

class EnemyPanel extends BasePanel with HasGameRef, AreaFillerMixin, ShakeMixin implements CombatWatcher {
  late EnemyBase enemy;
  TextComponent? actionText;
  TextComponent? descriptionText;
  RectangleComponent? separatorLine;
  SpriteComponent? enemySprite;
  AudioPlayer? audioPlayer;
  bool _isLoaded = false;
  late final StatsRow statsRow;
  late final NameEmojiComponent nameEmojiComponent;

  final EnemyPanelMode mode;

  EnemyPanel({this.mode = EnemyPanelMode.combat});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get the current enemy from DataController
    enemy = DataController.instance.get<EnemyBase>('selectedEnemy')!;

    // Add enemy sprite
    try {
      final image = await gameRef.images.load(enemy.imagePath);
      final sprite = Sprite(image);
      enemySprite = SpriteComponent(
        sprite: sprite,
        size: Vector2(200, 200),
      );
      addToVerticalStack(enemySprite!, 200);
    } catch (e) {
      GameLogger.error(LogCategory.ui, 'Failed to load enemy sprite: $e');
    }

    // Add enemy name + emoji
    nameEmojiComponent = NameEmojiComponent(character: enemy);
    addToVerticalStack(nameEmojiComponent, 30);

    // Add enemy stats row
    statsRow = StatsRow(character: enemy);
    addToVerticalStack(statsRow, 40);

    // Watch for changes to selectedEnemy (after nameText and statsRow are initialized)
    DataController.instance.watch('selectedEnemy', (value) {
      if (value is EnemyBase) {
        updateEnemy(value);
      }
    });

    // Load enemy sound
    try {
      audioPlayer = AudioPlayer();
      await audioPlayer?.setSource(AssetSource(enemy.soundPath));
      await audioPlayer?.setVolume(0.3); // Set volume to 30%
      await audioPlayer?.resume(); // Start playing
    } catch (e) {
      GameLogger.warning(LogCategory.audio, 'Failed to load enemy sound: $e');
    }

    if (mode == EnemyPanelMode.combat) {
      // Create text components for next action
      final initialAction = ActionWithEmojiComponent.format(
        enemy,
        enemy.getNextAction(),
      );
      actionText = TextComponent(
        text: 'Next Action: $initialAction',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      addToVerticalStack(actionText!, 20);
    } else if (mode == EnemyPanelMode.detail) {
      // Create description text
      descriptionText = TextComponent(
        text: _getEnemyDescription(enemy),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      addToVerticalStack(descriptionText!, 20);
    }

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
    if (_isLoaded) {
      statsRow.updateUI();
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
    nameEmojiComponent.updateCharacter(enemy);
    statsRow.setCharacter(enemy);
    if (mode == EnemyPanelMode.detail && descriptionText != null) {
      descriptionText!.text = _getEnemyDescription(enemy);
    }
    // TODO: Update sprite when enemy changes
  }

  String _getEnemyDescription(EnemyBase enemy) {
    // TODO: Replace with real description if available
    return 'A mysterious enemy with unique abilities.';
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
        shakeForType(event.card?.type ?? CardType.attack);
      } else if (event.type == CombatEventType.cure) {
        updateHealth();
      }
    }
  }
}

enum EnemyPanelMode { detail, combat } 