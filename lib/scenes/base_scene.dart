import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class BaseScene extends FlameGame {
  final Color sceneBackgroundColor;
  final Map<String, dynamic>? options;

  BaseScene({
    required this.sceneBackgroundColor,
    this.options,
  });

  @override
  Color backgroundColor() => sceneBackgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Scene loaded: $runtimeType');
    if (options != null) {
      initialize(options!);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    // Remove all components from the scene
    for (final component in children.toList()) {
      component.removeFromParent();
    }
    GameLogger.debug(LogCategory.game, 'Scene removed: $runtimeType');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawColor(sceneBackgroundColor, BlendMode.src);
  }

  void onBack() {
    // Override in subclasses if needed
  }

  void initialize(Map<String, dynamic> params) {
    GameLogger.debug(
        LogCategory.game, 'Scene initialized with params: $params');
  }
}
