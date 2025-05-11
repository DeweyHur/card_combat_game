import 'package:flame/game.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/player_selection_scene.dart';
import 'package:card_combat_app/scenes/combat_scene.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class SceneManager {
  static SceneManager? _instance;
  static SceneManager get instance {
    _instance ??= SceneManager._internal();
    return _instance!;
  }

  SceneManager._internal();

  FlameGame? _game;
  final Map<String, BaseScene Function()> _scenes = {};
  final Map<String, BaseScene Function(PlayerBase, EnemyBase)> _paramScenes = {};

  void initialize(FlameGame game) {
    _game = game;
    _registerScenes();
    GameLogger.info(LogCategory.game, 'SceneManager initialized');
  }

  void _registerScenes() {
    // Register regular scenes
    _scenes['player_selection'] = () => PlayerSelectionScene();

    // Register parameterized scenes
    _paramScenes['combat'] = (player, enemy) => CombatScene(
      player: player,
      enemy: enemy,
    );
    GameLogger.info(LogCategory.game, 'Scenes registered');
  }

  void registerScene(String name, BaseScene Function() sceneFactory) {
    _scenes[name] = sceneFactory;
    GameLogger.info(LogCategory.game, 'Registered scene: $name');
  }

  void registerSceneWithParams(
    String name,
    BaseScene Function(PlayerBase, EnemyBase) sceneFactory,
  ) {
    _paramScenes[name] = sceneFactory;
    GameLogger.info(LogCategory.game, 'Registered scene with params: $name');
  }

  void pushScene(String name, [dynamic param1, dynamic param2]) {
    if (_game == null) {
      GameLogger.error(LogCategory.game, 'SceneManager not initialized with game');
      return;
    }

    final currentScene = _game!.children.whereType<BaseScene>().firstOrNull;
    if (currentScene != null) {
      _game!.remove(currentScene);
    }

    BaseScene? newScene;
    if (_scenes.containsKey(name)) {
      newScene = _scenes[name]!();
    } else if (_paramScenes.containsKey(name)) {
      if (param1 == null || param2 == null) {
        GameLogger.error(LogCategory.game, 'Parameters required for scene: $name');
        return;
      }
      if (param1 is! PlayerBase || param2 is! EnemyBase) {
        GameLogger.error(LogCategory.game, 'Invalid parameter types for scene: $name');
        return;
      }
      newScene = _paramScenes[name]!(param1, param2);
    } else {
      GameLogger.error(LogCategory.game, 'Scene not found: $name');
      return;
    }

    _game!.add(newScene);
    GameLogger.info(LogCategory.game, 'Pushed scene: $name');
  }
} 