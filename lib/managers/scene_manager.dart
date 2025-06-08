import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class SceneManager {
  final FlameGame game;
  final Map<String, dynamic> _sceneData = {};

  SceneManager(this.game);

  void pushScene(Component scene) {
    game.add(scene);
    GameLogger.info(LogCategory.game, 'Pushed scene: ${scene.runtimeType}');
  }

  void popScene() {
    if (game.children.isNotEmpty) {
      final scene = game.children.last;
      game.remove(scene);
      GameLogger.info(LogCategory.game, 'Popped scene: ${scene.runtimeType}');
    }
  }

  void setSceneData(String key, dynamic value) {
    _sceneData[key] = value;
  }

  dynamic getSceneData(String key) {
    return _sceneData[key];
  }

  void clearSceneData() {
    _sceneData.clear();
  }
}
