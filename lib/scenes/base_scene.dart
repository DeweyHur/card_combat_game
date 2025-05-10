import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/card_combat_game.dart';
import 'scene_controller.dart';
import '../utils/game_logger.dart';

class BaseScene extends Component {
  final FlameGame game;
  late SceneController sceneController;
  final Color backgroundColor;

  BaseScene({
    required this.game,
    this.backgroundColor = const Color(0xFF1A1A2E),
  }) {
    sceneController = SceneController(game);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game, 'Scene loaded: ${runtimeType}');
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
    super.render(canvas);
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
} 