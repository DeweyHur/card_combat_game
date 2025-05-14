import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class BaseScene extends FlameGame {
  final Color sceneBackgroundColor;

  BaseScene({
    required this.sceneBackgroundColor,
  });

  @override
  Color backgroundColor() => sceneBackgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Scene loaded: $runtimeType');
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.debug(LogCategory.game, 'Scene mounted: $runtimeType');
  }

  @override
  void onRemove() {
    // Remove all components from the scene
    for (final component in children.toList()) {
      component.removeFromParent();
    }
    GameLogger.debug(LogCategory.game, 'Scene removed: $runtimeType');
    super.onRemove();
  }


  @override
  void render(Canvas canvas) {
    canvas.drawColor(sceneBackgroundColor, BlendMode.src);
  }

  void onBack() {
    // Override in subclasses if needed
  }

  void initialize(Map<String, dynamic> params) {
    GameLogger.debug(LogCategory.game, 'Scene initialized with params: $params');
  }
} 