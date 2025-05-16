import 'package:flame/game.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/title_scene.dart';
import 'package:card_combat_app/scenes/player_selection_scene.dart';
import 'package:card_combat_app/scenes/combat_scene.dart';
import 'package:card_combat_app/scenes/game_result_scene.dart';
import 'package:card_combat_app/scenes/card_upgrade_scene.dart';
import 'base_scene.dart';

class SceneManager {
  static final SceneManager _instance = SceneManager._internal();
  factory SceneManager() => _instance;
  SceneManager._internal();

  FlameGame? _game;
  final Map<String, BaseScene Function()> _scenes = {};

  void initialize(FlameGame game) {
    _game = game;
    _registerScenes();
    GameLogger.info(LogCategory.game, 'SceneManager initialized');
  }

  void _registerScenes() {
    registerScene('title', () => TitleScene());
    registerScene('player_selection', () => PlayerSelectionScene());
    registerScene('combat', () => CombatScene());
    registerScene('game_result', () => GameResultScene());
    registerScene('card_upgrade', () => CardUpgradeScene());
    GameLogger.info(LogCategory.game, 'Scenes registered');
  }

  void registerScene(String name, BaseScene Function() sceneFactory) {
    _scenes[name] = sceneFactory;
    GameLogger.info(LogCategory.game, 'Registered scene: $name');
  }

  void pushScene(String name) {
    if (_game == null) {
      GameLogger.error(LogCategory.game, 'SceneManager not initialized with game');
      return;
    }

    if (!_scenes.containsKey(name)) {
      GameLogger.error(LogCategory.game, 'Scene not found: $name');
      return;
    }

    final currentScene = _game!.children.whereType<BaseScene>().firstOrNull;
    if (currentScene != null) {
      _game!.remove(currentScene);
    }

    final newScene = _scenes[name]!();
    _game!.add(newScene);
    GameLogger.info(LogCategory.game, 'Pushed scene: $name');
  }
} 