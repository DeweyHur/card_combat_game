import 'package:flame/game.dart';
import '../utils/game_logger.dart';
import 'base_scene.dart';
import 'player_selection_scene.dart';
import 'combat_scene.dart';
import '../game/card_combat_game.dart';
import '../models/characters/player_base.dart';

class SceneController {
  final FlameGame game;
  final Map<String, BaseScene> _scenes = {};
  BaseScene? _currentScene;

  SceneController(this.game);

  void registerScene(String name, BaseScene scene) {
    _scenes[name] = scene;
    GameLogger.debug(LogCategory.game, 'Scene registered: $name');
  }

  void go(String sceneName, {Map<String, dynamic>? params}) {
    if (!_scenes.containsKey(sceneName)) {
      GameLogger.error(LogCategory.game, 'Scene not found: $sceneName');
      return;
    }

    final scene = _scenes[sceneName]!;
    if (_currentScene != null) {
      game.remove(_currentScene!);
    }
    _currentScene = scene;
    if (params != null) {
      scene.initialize(params);
    }
    game.add(scene);
    GameLogger.info(LogCategory.game, 'Switched to scene: ${scene.runtimeType}');
  }

  void goToScene(BaseScene scene) {
    if (_currentScene != null) {
      game.remove(_currentScene!);
    }
    _currentScene = scene;
    game.add(scene);
    GameLogger.info(LogCategory.game, 'Switched to scene: ${scene.runtimeType}');
  }

  BaseScene? getCurrentScene() {
    return _currentScene;
  }

  void clearCache() {
    _scenes.clear();
    GameLogger.debug(LogCategory.game, 'Scene cache cleared');
  }

  void clearCacheExcept(String sceneName) {
    GameLogger.info(LogCategory.game, '=== Clearing Scene Cache Except ===');
    GameLogger.debug(LogCategory.game, 'Keeping scene: $sceneName');
    GameLogger.debug(LogCategory.game, 'Cache size before: ${_scenes.length}');
    _scenes.removeWhere((key, scene) => key != sceneName);
    GameLogger.debug(LogCategory.game, 'Cache size after: ${_scenes.length}');
  }
} 