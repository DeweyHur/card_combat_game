import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';

abstract class BaseEnemyPanel extends BasePanel
    with HasGameReference, AreaFillerMixin, ShakeMixin
    implements CombatWatcher {
  late GameCharacter enemy;
  RectangleComponent? separatorLine;
  SpriteComponent? enemySprite;
  AudioPlayer? audioPlayer;
  bool _isLoaded = false;
  late final StatsRow statsRow;
  late final NameEmojiComponent nameEmojiComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    enemy = DataController.instance.get<GameCharacter>('selectedEnemy')!;
    try {
      final image = await findGame()!.images.load(enemy.imagePath);
      final sprite = Sprite(image);
      enemySprite = SpriteComponent(
        sprite: sprite,
      );
      registerVerticalStackComponent('enemySprite', enemySprite!, 200);
    } catch (e) {
      GameLogger.error(LogCategory.ui, 'Failed to load enemy sprite: $e');
    }
    nameEmojiComponent = NameEmojiComponent(character: enemy);
    registerVerticalStackComponent('nameEmoji', nameEmojiComponent, 60);
    statsRow = StatsRow(character: enemy);
    registerVerticalStackComponent('statsRow', statsRow, 20);
    DataController.instance.watch('selectedEnemy', (value) {
      if (value is GameCharacter) {
        updateEnemy(value);
      }
    });
    try {
      audioPlayer = AudioPlayer();
      await audioPlayer?.setSource(AssetSource('sounds/${enemy.soundPath}'));
      await audioPlayer?.setVolume(0.3);
      await audioPlayer?.resume();
    } catch (e) {
      GameLogger.warning(LogCategory.audio, 'Failed to load enemy sound: $e');
    }
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      paint: Paint()..color = Colors.white.withAlpha(128),
    );
    registerVerticalStackComponent('separatorLine', separatorLine!, 2);
    _isLoaded = true;
    GameLogger.debug(LogCategory.ui, 'BaseEnemyPanel loaded successfully');
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

  void updateEnemy(GameCharacter newEnemy) {
    enemy = newEnemy;
    nameEmojiComponent.updateCharacter(enemy);
    statsRow.setCharacter(enemy);
  }

  @override
  void onRemove() {
    audioPlayer?.stop();
    audioPlayer?.dispose();
    super.onRemove();
  }

  void showEffectForCard(dynamic card, VoidCallback onComplete) {
    final effect = GameEffects.createCardEffect(
      card.type,
      Vector2(size.x / 2 - 50, size.y / 2 - 50),
      Vector2(100, 100),
      onComplete: onComplete,
    )..priority = 100;
    add(effect);
  }

  List<String> splitTextToLines(String text, TextStyle style, double maxWidth) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      tp.text = TextSpan(text: testLine, style: style);
      tp.layout();
      if (tp.width > maxWidth && currentLine.isNotEmpty) {
        lines.add(currentLine);
        currentLine = word;
      } else {
        currentLine = currentLine.isEmpty ? word : '$currentLine $word';
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines;
  }
}
