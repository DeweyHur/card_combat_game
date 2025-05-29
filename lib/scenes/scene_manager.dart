import 'package:flame/game.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/title_scene.dart';
import 'package:card_combat_app/scenes/player_selection_scene.dart';
import 'package:card_combat_app/scenes/combat_scene.dart';
import 'package:card_combat_app/scenes/game_result_scene.dart';
import 'package:card_combat_app/scenes/card_upgrade_scene.dart';
import 'package:card_combat_app/scenes/armory_scene.dart';
import 'package:card_combat_app/scenes/inventory_scene.dart';
import 'package:card_combat_app/scenes/map_scene.dart';
import 'package:card_combat_app/scenes/outpost_scene.dart';
import 'package:card_combat_app/scenes/shop_scene.dart';
import 'package:card_combat_app/scenes/tavern_scene.dart';
import 'package:card_combat_app/scenes/credit_scene.dart';
import 'package:card_combat_app/scenes/expedition_scene.dart';
import 'base_scene.dart';

class SceneManager {
  static final SceneManager _instance = SceneManager._internal();
  factory SceneManager() => _instance;
  SceneManager._internal();

  FlameGame? _game;
  final Map<String, BaseScene Function(Map<String, dynamic>? options)> _scenes =
      {};
  final List<String> _sceneStack = [];

  void initialize(FlameGame game) {
    _game = game;
    _registerScenes();
    GameLogger.info(LogCategory.game, 'SceneManager initialized');
  }

  void _registerScenes() {
    registerScene('title', (options) => TitleScene(options: options));
    registerScene('player_selection',
        (options) => PlayerSelectionScene(options: options));
    registerScene('outpost', (options) => OutpostScene(options: options));
    registerScene('combat', (options) => CombatScene(options: options));
    registerScene(
        'game_result', (options) => GameResultScene(options: options));
    registerScene(
        'card_upgrade', (options) => CardUpgradeScene(options: options));
    registerScene('equipment', (options) => ArmoryScene(options: options));
    registerScene('inventory', (options) => InventoryScene(options: options));
    registerScene('map', (options) => MapScene(options: options));
    registerScene('shop', (options) => ShopScene(options: options));
    registerScene('tavern', (options) => TavernScene(options: options));
    registerScene('credit', (options) => CreditScene(options: options));
    registerScene('expedition', (options) => ExpeditionScene(options: options));
    GameLogger.info(LogCategory.game, 'Scenes registered');
  }

  void registerScene(String name,
      BaseScene Function(Map<String, dynamic>? options) sceneFactory) {
    _scenes[name] = sceneFactory;
    GameLogger.info(LogCategory.game, 'Registered scene: $name');
  }

  void pushScene(String name, {Map<String, dynamic>? options}) {
    if (_game == null) {
      GameLogger.error(
          LogCategory.game, 'SceneManager not initialized with game');
      return;
    }
    if (!_scenes.containsKey(name)) {
      GameLogger.error(LogCategory.game, 'Scene not found: $name');
      return;
    }
    final currentScene = _game!.children.whereType<BaseScene>().firstOrNull;
    if (currentScene != null) {
      // Find the current scene's name and push to stack
      final currentName = _scenes.entries
          .firstWhere(
            (entry) =>
                currentScene.runtimeType == entry.value(null).runtimeType,
            orElse: () =>
                MapEntry('', (options) => throw Exception('No scene found')),
          )
          .key;
      if (currentName.isNotEmpty) {
        _sceneStack.add(currentName);
      }
      _game!.remove(currentScene);
    }
    final newScene = _scenes[name]!(options);
    _game!.add(newScene);
    GameLogger.info(
        LogCategory.game, 'Pushed scene: $name (stack: $_sceneStack)');
    GameLogger.debug(LogCategory.game, 'Scene stack after push: $_sceneStack');
  }

  void popScene({Map<String, dynamic>? options}) {
    if (_game == null) {
      GameLogger.error(
          LogCategory.game, 'SceneManager not initialized with game');
      return;
    }
    if (_sceneStack.isEmpty) {
      GameLogger.warning(LogCategory.game, 'Scene stack is empty, cannot pop');
      return;
    }
    final currentScene = _game!.children.whereType<BaseScene>().firstOrNull;
    if (currentScene != null) {
      _game!.remove(currentScene);
    }
    final prevSceneName = _sceneStack.removeLast();
    final prevScene = _scenes[prevSceneName]?.call(options);
    if (prevScene != null) {
      _game!.add(prevScene);
      GameLogger.info(LogCategory.game,
          'Popped to scene: $prevSceneName (stack: $_sceneStack)');
      GameLogger.debug(LogCategory.game, 'Scene stack after pop: $_sceneStack');
    } else {
      GameLogger.error(
          LogCategory.game, 'Previous scene not found: $prevSceneName');
    }
  }

  void moveScene(String name, {Map<String, dynamic>? options}) {
    if (_game == null) {
      GameLogger.error(
          LogCategory.game, 'SceneManager not initialized with game');
      return;
    }
    if (!_scenes.containsKey(name)) {
      GameLogger.error(LogCategory.game, 'Scene not found: $name');
      return;
    }
    // Remove current scene
    final currentScene = _game!.children.whereType<BaseScene>().firstOrNull;
    if (currentScene != null) {
      _game!.remove(currentScene);
    }
    // Clear the stack
    _sceneStack.clear();
    // Add the new scene
    final newScene = _scenes[name]!(options);
    _game!.add(newScene);
    GameLogger.info(LogCategory.game, 'Moved to scene: $name (stack cleared)');
    GameLogger.debug(LogCategory.game, 'Scene stack after move: $_sceneStack');
  }
}
