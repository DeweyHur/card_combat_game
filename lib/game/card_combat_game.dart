import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:audioplayers/audioplayers.dart';

import '../models/game_card.dart';
import '../models/game_cards_data.dart';
import '../components/card_visual_component.dart';
import '../components/game_effects.dart';
import '../scenes/player_selection_scene.dart';
import '../scenes/scene_controller.dart';
import '../utils/game_logger.dart';
import '../scenes/base_scene.dart';
import '../scenes/combat_scene.dart';
import '../models/player.dart';
import '../models/enemies/goblin.dart';

class CardCombatGame extends FlameGame with TapDetector {
  late TextComponent _playerHpText;
  late TextComponent _enemyHpText;
  late TextComponent _enemyActionText;
  late TextComponent _cardAreaText;
  late TextComponent _gameInfoText;
  late TextComponent _turnText;
  late RectangleComponent _playerArea;
  late RectangleComponent _enemyArea;
  late RectangleComponent _cardArea;

  late List<GameCard> _cardPool;
  final List<GameCard> _currentHand = [];
  final List<Component> _cardVisuals = [];
  final Random _random = Random();

  int playerHp = 30;
  int maxPlayerHp = 30;
  int enemyHp = 20;
  int maxEnemyHp = 20;
  String enemyNextAction = "";
  bool isPlayerTurn = true;
  int turnCount = 1;
  
  // Goblin enemy actions
  static const List<Map<String, dynamic>> _goblinActions = [
    {'name': 'Slash', 'damage': 5, 'description': 'Slash for 5 damage'},
    {'name': 'Rage', 'damage': 8, 'description': 'Rage attack for 8 damage'},
    {'name': 'Scratch', 'damage': 3, 'description': 'Scratch for 3 damage'},
  ];
  Map<String, dynamic> _currentEnemyAction = {};

  static final cardTextStyle = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  static final cardDescriptionStyle = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  );

  bool _audioEnabled = false;
  late SceneController sceneController;
  late BaseScene currentScene;
  final AudioPlayer _audioPlayer = AudioPlayer();

  CardCombatGame() {
    sceneController = SceneController(this);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.info(LogCategory.game, 'CardCombatGame initialized');

    try {
      GameLogger.info(LogCategory.system, '=== Game Initialization Started ===');
      
      // Initialize audio
      _audioEnabled = await _initializeAudio();
      GameLogger.info(LogCategory.system, 'Audio initialized: $_audioEnabled');

      // Create a test player
      final player = Player(
        name: 'Hero',
        maxHealth: 50,
      );

      // Create and register combat scene
      final combatScene = CombatScene(
        game: this,
        player: player,
        enemy: Goblin(),
      );
      sceneController.registerScene('combat', combatScene);

      // Start with combat scene
      sceneController.go('combat');

      GameLogger.info(LogCategory.system, '=== Game Initialization Completed ===');
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.system, 'Error during game initialization: $e\n$stackTrace');
    }
  }

  Future<bool> _initializeAudio() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
      GameLogger.info(LogCategory.audio, 'Audio player initialized successfully');
      return true;
    } catch (e) {
      GameLogger.error(LogCategory.audio, 'Failed to initialize audio: $e');
      return false;
    }
  }

  Future<void> playCardSound() async {
    if (_audioEnabled) {
      try {
        await _audioPlayer.play(AssetSource('sounds/card_play.mp3'));
      } catch (e) {
        GameLogger.error(LogCategory.audio, 'Failed to play card sound: $e');
      }
    }
  }

  void changeScene(BaseScene newScene) {
    remove(currentScene);
    currentScene = newScene;
    add(currentScene);
    GameLogger.info(LogCategory.game, 'Scene changed to ${newScene.runtimeType}');
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.info(LogCategory.system, 'Game mounted');
  }

  Future<void> _createGameAreas() async {
    _playerArea = RectangleComponent(
      size: Vector2(size.x, size.y * 0.3),
      position: Vector2(0, size.y * 0.7),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    add(_playerArea);

    _enemyArea = RectangleComponent(
      size: Vector2(size.x, size.y * 0.3),
      position: Vector2(0, 0),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    add(_enemyArea);

    _cardArea = RectangleComponent(
      size: Vector2(size.x, size.y * 0.4),
      position: Vector2(0, size.y * 0.3),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    add(_cardArea);
    
    GameLogger.info(LogCategory.system, 'Game areas created');
  }

  Future<void> _createCharacters() async {
    final playerCharacter = RectangleComponent(
      size: Vector2(50, 50),
      position: Vector2(size.x * 0.2, size.y * 0.7 + 25),
      paint: Paint()..color = const Color(0xFF3498DB),
    );
    add(playerCharacter);

    final enemyCharacter = RectangleComponent(
      size: Vector2(50, 50),
      position: Vector2(size.x * 0.2, 25),
      paint: Paint()..color = const Color(0xFFE74C3C),
    );
    add(enemyCharacter);
    
    GameLogger.info(LogCategory.system, 'Characters created');
  }

  Future<void> _createUI() async {
    _playerHpText = TextComponent(
      text: 'HP: $playerHp/$maxPlayerHp',
      position: Vector2(size.x * 0.2, size.y * 0.7 + 80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_playerHpText);

    _enemyHpText = TextComponent(
      text: 'HP: $enemyHp/$maxEnemyHp',
      position: Vector2(size.x * 0.2, 80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_enemyHpText);

    _enemyActionText = TextComponent(
      text: 'Next Action: $enemyNextAction',
      position: Vector2(size.x * 0.2, 120),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    add(_enemyActionText);

    _cardAreaText = TextComponent(
      text: 'Cards',
      position: Vector2(size.x * 0.5, size.y * 0.3 + 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_cardAreaText);

    _gameInfoText = TextComponent(
      text: 'Turn: $turnCount',
      position: Vector2(size.x * 0.8, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    add(_gameInfoText);

    _turnText = TextComponent(
      text: isPlayerTurn ? 'Your Turn' : 'Enemy Turn',
      position: Vector2(size.x * 0.8, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_turnText);
    
    GameLogger.info(LogCategory.system, 'UI elements created');
  }

  void _drawInitialHand() {
    for (int i = 0; i < 3; i++) {
      if (_cardPool.isNotEmpty) {
        final card = _cardPool.removeAt(_random.nextInt(_cardPool.length));
        _currentHand.add(card);
        final cardVisual = _createCardVisual(card, i);
        _cardVisuals.add(cardVisual);
        add(cardVisual);
      }
    }
    GameLogger.info(LogCategory.system, 'Initial hand drawn');
  }

  void _drawNewHand() {
    GameLogger.info(LogCategory.system, '\n=== Drawing New Hand ===');
    // Remove old card visuals
    for (var visual in _cardVisuals) {
      remove(visual);
    }
    _cardVisuals.clear();
    _currentHand.clear();

    if (_cardPool.isEmpty) {
      GameLogger.error(LogCategory.system, 'ERROR: Card pool is empty!');
      return;
    }

    // Draw 3 random cards
    for (int i = 0; i < 3; i++) {
      final card = _cardPool[_random.nextInt(_cardPool.length)];
      _currentHand.add(card);
      GameLogger.info(LogCategory.system, 'Drew card: ${card.name} (${card.type})');
    }

    // Create visuals for the new hand
    for (int i = 0; i < _currentHand.length; i++) {
      final cardData = _currentHand[i];
      final cardVisual = _createCardVisual(cardData, i);
      add(cardVisual);
      _cardVisuals.add(cardVisual);
    }
    GameLogger.info(LogCategory.system, 'Hand drawn and visuals created');
  }

  Component _createCardVisual(GameCard cardData, int index) {
    final cardWidth = 140.0;
    final cardHeight = 180.0;
    final spacing = 20.0;
    final totalWidth = (_currentHand.length * cardWidth) + ((_currentHand.length -1) * spacing);
    final startX = _cardArea.position.x + (_cardArea.size.x - totalWidth) / 2;

    final position = Vector2(
      startX + (index * (cardWidth + spacing)),
      _cardArea.position.y + 60,
    );
    return CardVisualComponent(
      cardData,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: _executeCard,
      enabled: isPlayerTurn,
    );
  }

  void _executeCard(GameCard card) {
    GameLogger.info(LogCategory.game, '\n=== Playing Card ===');
    GameLogger.info(LogCategory.game, 'Card played: ${card.name} (${card.type})');
    
    // Play card effect
    final effect = GameEffects.createCardEffect(
      card.type,
      Vector2(size.x / 2, size.y / 2),
      Vector2(100, 100),
    );
    add(effect);
    
    switch (card.type) {
      case CardType.attack:
        GameLogger.info(LogCategory.game, 'Attack card: ${card.value} damage');
        enemyHp -= card.value.toInt();
        if (enemyHp < 0) enemyHp = 0;
        _enemyHpText.text = 'Goblin HP: $enemyHp/$maxEnemyHp';
        GameLogger.info(LogCategory.game, 'Enemy HP reduced to: $enemyHp');
        
        // Play damage effect on enemy
        final damageEffect = GameEffects.createDamageEffect(
          Vector2(_enemyArea.position.x + _enemyArea.size.x / 2, _enemyArea.position.y + 40),
          card.value.toInt(),
          false,
        );
        add(damageEffect);
        break;
        
      case CardType.heal:
      case CardType.cure:
        GameLogger.info(LogCategory.game, '${card.type} card: ${card.value} HP');
        playerHp += card.value.toInt();
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _playerHpText.text = 'HP: $playerHp/$maxPlayerHp';
        GameLogger.info(LogCategory.game, 'Player HP increased to: $playerHp');
        break;
        
      case CardType.statusEffect:
        GameLogger.info(LogCategory.game, 'Status effect card: ${card.statusEffectToApply}');
        // TODO: Implement status effects
        break;
    }

    // Check for victory
    if (enemyHp <= 0) {
      GameLogger.info(LogCategory.system, 'Victory: Enemy defeated!');
      _gameInfoText.text = 'Victory! You defeated the Goblin!';
      return;
    }

    // End player turn, start enemy turn
    GameLogger.info(LogCategory.system, 'Ending player turn');
    isPlayerTurn = false;
    _cardAreaText.text = 'Enemy Turn';
    
    // Remove cards from hand
    for (var visual in _cardVisuals) {
      remove(visual);
    }
    _cardVisuals.clear();
    _currentHand.clear();

    // Schedule enemy turn
    GameLogger.info(LogCategory.system, 'Scheduling enemy turn');
    Future.delayed(Duration(seconds: 1), _executeEnemyTurn);
  }

  void _executeEnemyTurn() {
    GameLogger.info(LogCategory.system, '\n=== Enemy Turn ===');
    final damage = _currentEnemyAction['damage'] as int;
    GameLogger.info(LogCategory.system, 'Enemy action: ${_currentEnemyAction['name']} for $damage damage');
    
    // Apply enemy action
    playerHp -= damage;
    if (playerHp < 0) playerHp = 0;
    GameLogger.info(LogCategory.system, 'Player HP reduced to: $playerHp');
    
    // Play damage effect on player
    final damageEffect = GameEffects.createDamageEffect(
      Vector2(_playerArea.position.x + _playerArea.size.x / 2, _playerArea.position.y + 40),
      damage,
      true,
    );
    add(damageEffect);
    
    // Update UI
    _playerHpText.text = 'HP: $playerHp/$maxPlayerHp';
    
    // Check for game over
    if (playerHp <= 0) {
      GameLogger.info(LogCategory.system, 'Game Over: Player defeated!');
      _gameInfoText.text = 'Game Over! You were defeated by the Goblin!';
      return;
    }
    
    // Start new player turn
    isPlayerTurn = true;
    turnCount++;
    _turnText.text = 'Turn $turnCount';
    _setNextEnemyAction();
    _enemyActionText.text = 'Next: $enemyNextAction';
    _cardAreaText.text = 'Your Turn - Choose a Card';
    GameLogger.info(LogCategory.system, 'Starting turn $turnCount');
    GameLogger.info(LogCategory.system, 'Next enemy action: $enemyNextAction');
    _drawNewHand();
  }

  void _setNextEnemyAction() {
    _currentEnemyAction = _goblinActions[_random.nextInt(_goblinActions.length)];
    enemyNextAction = _currentEnemyAction['description'] as String;
    _enemyActionText.text = 'Next Action: $enemyNextAction';
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  void onRemove() {
    GameLogger.debug(LogCategory.system, 'Game being removed, cleaning up resources');
    _audioPlayer.dispose();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    GameLogger.debug(LogCategory.system, 'Game resized to: ${size.x}x${size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > 0.1) {
      GameLogger.warning(LogCategory.system, 'Game update with high dt: $dt');
    }
  }

  @override
  void render(Canvas canvas) {
    try {
      super.render(canvas);
    } catch (e, stackTrace) {
      GameLogger.error(LogCategory.system, 'Error in render: $e');
      GameLogger.debug(LogCategory.system, 'Stack trace: $stackTrace');
      rethrow;
    }
  }

  void initializeCardPool() {
    _cardPool = List.from(gameCards);
  }

  void onCardTap(CardVisualComponent cardVisual) {
    if (!isPlayerTurn) return;
    _executeCard(cardVisual.cardData);
  }
} 