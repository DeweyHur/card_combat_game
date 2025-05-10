import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/game/card_combat_game.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'scene_controller.dart';

class BaseScene extends Component with TapCallbacks, HasGameRef {
  final Color backgroundColor;

  BaseScene({
    required this.backgroundColor,
  });

  late SceneController sceneController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Scene loaded: ${runtimeType}');
    sceneController = (game as CardCombatGame).sceneController;
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.debug(LogCategory.game, 'Scene mounted: ${runtimeType}');
  }

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.game, 'Scene removed: ${runtimeType}');
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(backgroundColor, BlendMode.src);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }

  void onBack() {
    // Override in subclasses if needed
  }

  void initialize(Map<String, dynamic> params) {
    GameLogger.debug(LogCategory.game, 'Scene initialized with params: $params');
  }

  void go(String sceneName, {Map<String, dynamic>? params}) {
    sceneController.go(sceneName, params: params);
  }

  CardCombatGame get game => super.game as CardCombatGame;
} 