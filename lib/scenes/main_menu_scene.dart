import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/main_menu_layout.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'base_scene.dart';

class MainMenuScene extends BaseScene with TapCallbacks {
  late final MainMenuLayout _layout;

  MainMenuScene() : super(
    sceneBackgroundColor: const Color(0xFF1A1A2E),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'MainMenuScene loading...');

    _layout = MainMenuLayout(
      gameSize: game.size,
    );
    add(_layout);

    GameLogger.info(LogCategory.game, 'Main menu started');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _layout.handleTap(event.canvasPosition);
  }
} 