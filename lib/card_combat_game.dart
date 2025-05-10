import 'dart:math'; // For Random

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/events.dart'; // Updated import for input handling
import 'package:flame/effects.dart'; // For animations
import 'package:flutter/material.dart' hide Card; // For TextStyle and Colors, hide Material Card
import 'package:card_combat_app/card.dart'; // Import our Card class
import 'package:card_combat_app/cards_data.dart'; // Import our card data
import 'package:audioplayers/audioplayers.dart'; // For sound effects

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

  late List<Card> _cardPool;
  final List<Card> _currentHand = [];
  final List<Component> _cardVisuals = []; // To keep track of card visual components
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
      color: Colors.black,
      fontSize: 16,
      fontFamily: 'monospace', // Changed from PressStart2P to monospace
    ),
  );

  static final cardDescriptionStyle = TextPaint(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontFamily: 'monospace', // Changed from PressStart2P to monospace
    ),
  );

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> onLoad() async {
    try {
      print('Game initialization started');
      print('Screen size: ${size.x}x${size.y}');
      
      // Initialize audio player with error handling
      try {
        print('Initializing audio player...');
        await _audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
        print('Audio player initialized successfully');
        
        // Test sound playback
        print('Testing sound playback...');
        await _audioPlayer.play(AssetSource('sounds/card_play.mp3'));
        print('Test sound played successfully');
      } catch (e) {
        print('Error initializing audio player: $e');
      }

      // Create game areas with pixel art style
      _playerArea = RectangleComponent(
        size: Vector2(size.x, size.y * 0.3),
        position: Vector2(0, size.y * 0.7),
        paint: Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      add(_playerArea);

      // Add pixel art border to player area
      final playerBorder = RectangleComponent(
        size: Vector2(size.x, size.y * 0.3),
        position: Vector2(0, size.y * 0.7),
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      add(playerBorder);

      _enemyArea = RectangleComponent(
        size: Vector2(size.x, size.y * 0.3),
        position: Vector2(0, 0),
        paint: Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      add(_enemyArea);

      // Add pixel art border to enemy area
      final enemyBorder = RectangleComponent(
        size: Vector2(size.x, size.y * 0.3),
        position: Vector2(0, 0),
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      add(enemyBorder);

      _cardArea = RectangleComponent(
        size: Vector2(size.x, size.y * 0.4),
        position: Vector2(0, size.y * 0.3),
        paint: Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      add(_cardArea);

      // Add pixel art border to card area
      final cardBorder = RectangleComponent(
        size: Vector2(size.x, size.y * 0.4),
        position: Vector2(0, size.y * 0.3),
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      add(cardBorder);

      // Add player character
      final playerCharacter = RectangleComponent(
        size: Vector2(50, 50),
        position: Vector2(size.x * 0.2, size.y * 0.7 + 25),
        paint: Paint()..color = const Color(0xFF3498DB),
      );
      add(playerCharacter);
      print('Player character added');

      // Add enemy character
      final enemyCharacter = RectangleComponent(
        size: Vector2(50, 50),
        position: Vector2(size.x * 0.2, 25),
        paint: Paint()..color = const Color(0xFFE74C3C),
      );
      add(enemyCharacter);
      print('Enemy character added');

      // Display health text
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
      print('Player health text added');

      _enemyHpText = TextComponent(
        text: 'HP: $enemyHp/$maxEnemyHp',
        position: Vector2(size.x * 0.2, 80),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black,
              ),
            ],
          ),
        ),
        priority: 1,
      );
      add(_enemyHpText);
      print('Enemy health text added');

      // Display enemy action text
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
      print('Enemy action text added');

      // Display card area text
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
      print('Card area text added');

      // Display game info text
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
      print('Game info text added');

      // Display turn text
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
      print('Turn text added');

      // Initialize card pool
      _cardPool = initializeCardPool();
      print('Card pool initialized');

      // Draw initial hand
      _drawInitialHand();
      print('Initial hand drawn');

      // Set initial enemy action
      _setNextEnemyAction();
      print('Initial enemy action set');

      print('Game initialization completed successfully');
    } catch (e, stackTrace) {
      print('Error during game initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _pickNewEnemyAction() {
    _currentEnemyAction = _goblinActions[_random.nextInt(_goblinActions.length)];
    enemyNextAction = _currentEnemyAction['description'];
    print('New enemy action selected: ${_currentEnemyAction['name']}');
  }

  void _drawNewHand() {
    print('\n=== Drawing New Hand ===');
    // Remove old card visuals
    for (var visual in _cardVisuals) {
      remove(visual);
    }
    _cardVisuals.clear();
    _currentHand.clear();

    if (_cardPool.isEmpty) {
      print('ERROR: Card pool is empty!');
      return;
    }

    // Draw 3 random cards
    for (int i = 0; i < 3; i++) {
      final card = _cardPool[_random.nextInt(_cardPool.length)];
      _currentHand.add(card);
      print('Drew card: ${card.name} (${card.type})');
    }

    // Create visuals for the new hand
    for (int i = 0; i < _currentHand.length; i++) {
      final cardData = _currentHand[i];
      final cardVisual = _createCardVisual(cardData, i);
      add(cardVisual);
      _cardVisuals.add(cardVisual);
    }
    print('Hand drawn and visuals created');
  }

  void _playCardEffect(Card card) {
    final effectColor = _getEffectColor(card.type);
    final effect = RectangleComponent(
      size: Vector2(100, 100),
      position: Vector2(size.x / 2, size.y / 2),
      paint: Paint()..color = effectColor.withOpacity(0.5),
    )..opacity = 1.0; // Set initial opacity
    add(effect);

    // Fade out effect with proper opacity handling
    effect.add(
      SequenceEffect(
        [
          ScaleEffect.by(
            Vector2.all(2.0),
            EffectController(duration: 0.3),
          ),
          OpacityEffect.to(
            0.0,
            EffectController(duration: 0.2),
          ),
        ],
        onComplete: () {
          remove(effect);
        },
      ),
    );
  }

  void _playDamageEffect(Vector2 position, bool isPlayer) {
    // Play damage sound with error handling
    try {
      print('Playing damage sound effect...');
      _audioPlayer.play(AssetSource('sounds/damage.mp3')).then((_) {
        print('Damage sound played successfully');
      }).catchError((error) {
        print('Error playing damage sound: $error');
      });
    } catch (e) {
      print('Error setting up damage sound: $e');
    }

    // Create damage number effect with Unicode symbol
    final damageText = TextComponent(
      text: isPlayer ? '💥 ${_currentEnemyAction['damage']}' : '💥 ${_currentHand.first.value}',
      position: position,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );

    // Add simple floating animation
    damageText.add(
      MoveEffect.by(
        Vector2(0, -50),
        EffectController(duration: 0.5, curve: Curves.easeOut),
        onComplete: () {
          remove(damageText);
        },
      ),
    );

    add(damageText);
  }

  Color _getEffectColor(CardType type) {
    switch (type) {
      case CardType.attack:
        return Colors.red;
      case CardType.heal:
        return Colors.green;
      case CardType.statusEffect:
        return Colors.purple;
      case CardType.cure:
        return Colors.blue;
    }
  }

  void _executeCard(Card card) {
    print('\n=== Playing Card ===');
    print('Card played: ${card.name} (${card.type})');
    print('Current game state:');
    print('- Player HP: $playerHp/$maxPlayerHp');
    print('- Enemy HP: $enemyHp/$maxEnemyHp');
    print('- Is player turn: $isPlayerTurn');
    
    // Play card sound effect with error handling
    try {
      print('Playing card sound effect...');
      _audioPlayer.play(AssetSource('sounds/card_play.mp3')).then((_) {
        print('Card sound played successfully');
      }).catchError((error) {
        print('Error playing card sound: $error');
      });
    } catch (e) {
      print('Error setting up card sound: $e');
    }
    
    // Play card effect
    print('Playing card visual effect...');
    _playCardEffect(card);
    
    switch (card.type) {
      case CardType.attack:
        print('Processing attack card: ${card.value} damage');
        enemyHp -= card.value;
        if (enemyHp < 0) enemyHp = 0;
        _enemyHpText.text = 'Goblin HP: $enemyHp/$maxEnemyHp';
        print('Enemy HP reduced to: $enemyHp');
        // Play damage effect on enemy
        _playDamageEffect(
          Vector2(_enemyArea.position.x + _enemyArea.size.x / 2, _enemyArea.position.y + 40),
          false,
        );
        break;
      case CardType.heal:
        print('Processing heal card: ${card.value} HP');
        playerHp += card.value;
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _playerHpText.text = 'HP: $playerHp/$maxPlayerHp';
        print('Player HP increased to: $playerHp');
        break;
      case CardType.statusEffect:
        print('Processing status effect card: ${card.statusEffectToApply}');
        // TODO: Implement status effects
        break;
      case CardType.cure:
        print('Processing cure card: ${card.value} HP');
        playerHp += card.value;
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _playerHpText.text = 'HP: $playerHp/$maxPlayerHp';
        print('Player HP increased to: $playerHp');
        break;
    }

    // Check for victory
    if (enemyHp <= 0) {
      print('Victory: Enemy defeated!');
      _gameInfoText.text = 'Victory! You defeated the Goblin!';
      return;
    }

    // End player turn, start enemy turn
    print('Ending player turn');
    isPlayerTurn = false;
    _cardAreaText.text = 'Enemy Turn';
    
    // Remove cards from hand
    print('Removing cards from hand...');
    for (var visual in _cardVisuals) {
      remove(visual);
    }
    _cardVisuals.clear();
    _currentHand.clear();
    print('Cards removed from hand');

    // Schedule enemy turn
    print('Scheduling enemy turn...');
    Future.delayed(Duration(seconds: 1), () {
      print('Executing scheduled enemy turn');
      _executeEnemyTurn();
    });
  }

  Component _createCardVisual(Card cardData, int index) {
    final cardWidth = 140.0;
    final cardHeight = 180.0;
    final spacing = 20.0;
    final totalWidth = (_currentHand.length * cardWidth) + ((_currentHand.length -1) * spacing);
    final startX = _cardArea.position.x + (_cardArea.size.x - totalWidth) / 2;

    final position = Vector2(
      startX + (index * (cardWidth + spacing)),
      _cardArea.position.y + 60, // Position cards below the area text
    );
    return CardVisualComponent(
      cardData,
      position: position,
      size: Vector2(cardWidth, cardHeight),
      onCardPlayed: _executeCard,
      enabled: isPlayerTurn,
    );
  }

  void _executeEnemyTurn() {
    print('\n=== Enemy Turn ===');
    final damage = _currentEnemyAction['damage'] as int;
    print('Enemy action: ${_currentEnemyAction['name']} for $damage damage');
    
    // Apply enemy action
    playerHp -= damage;
    if (playerHp < 0) playerHp = 0;
    print('Player HP reduced to: $playerHp');
    
    // Play damage effect on player
    _playDamageEffect(
      Vector2(_playerArea.position.x + _playerArea.size.x / 2, _playerArea.position.y + 40),
      true,
    );
    
    // Update UI
    _playerHpText.text = 'HP: $playerHp/$maxPlayerHp';
    
    // Check for game over
    if (playerHp <= 0) {
      print('Game Over: Player defeated!');
      _gameInfoText.text = 'Game Over! You were defeated by the Goblin!';
      return;
    }
    
    // Start new player turn
    print('Starting new player turn...');
    isPlayerTurn = true;
    turnCount++;
    _turnText.text = 'Turn $turnCount';
    _pickNewEnemyAction();
    _enemyActionText.text = 'Next: $enemyNextAction';
    _cardAreaText.text = 'Your Turn - Choose a Card';
    print('Starting turn $turnCount');
    print('Next enemy action: $enemyNextAction');
    _drawNewHand();
  }

  void _drawInitialHand() {
    // Draw 3 cards for the initial hand
    for (int i = 0; i < 3; i++) {
      if (_cardPool.isNotEmpty) {
        final card = _cardPool.removeAt(_random.nextInt(_cardPool.length));
        _currentHand.add(card);
        final cardVisual = _createCardVisual(card, i);
        _cardVisuals.add(cardVisual);
        add(cardVisual);
      }
    }
  }

  void _setNextEnemyAction() {
    _currentEnemyAction = _goblinActions[_random.nextInt(_goblinActions.length)];
    enemyNextAction = _currentEnemyAction['description'] as String;
    _enemyActionText.text = 'Next Action: $enemyNextAction';
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E); // Dark blue background

  @override
  void onRemove() {
    _audioPlayer.dispose();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    print('Game resized to: ${size.x}x${size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > 0.1) { // Only print if there's a significant delay
      print('Game update with dt: $dt');
    }
  }

  @override
  void render(Canvas canvas) {
    try {
      super.render(canvas);
    } catch (e, stackTrace) {
      print('Error in render: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

// New component for individual card visuals that can be tapped
class CardVisualComponent extends PositionComponent with TapCallbacks {
  final Card cardData;
  final Function(Card) onCardPlayed;
  final bool enabled;

  CardVisualComponent(
    this.cardData, {
    required Vector2 position,
    required Vector2 size,
    required this.onCardPlayed,
    required this.enabled,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Card background
    final backgroundPaint = Paint()
      ..color = enabled ? BasicPalette.white.color : BasicPalette.gray.color
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
    );
    add(cardBackground);

    // Card border
    final borderPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final cardBorder = RectangleComponent(
      size: size,
      paint: borderPaint,
    );
    add(cardBorder);

    // Card Name
    final nameText = TextComponent(
      text: cardData.name,
      textRenderer: CardCombatGame.cardTextStyle,
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    // Card Type
    final typeText = TextComponent(
      text: cardData.type.toString().split('.').last.toUpperCase(),
      textRenderer: CardCombatGame.cardDescriptionStyle,
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
    );
    add(typeText);

    // Card Description
    final descText = TextComponent(
      text: cardData.description,
      textRenderer: CardCombatGame.cardDescriptionStyle,
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.bottomCenter,
    );
    add(descText);

    // Card Value
    if (cardData.type == CardType.attack || cardData.type == CardType.heal) {
      final valueText = TextComponent(
        text: cardData.value.toString(),
        textRenderer: TextPaint(
          style: TextStyle(
            color: _getCardColor(),
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
      add(valueText);
    }
  }

  Color _getCardColor() {
    switch (cardData.type) {
      case CardType.attack:
        return Colors.red;
      case CardType.heal:
        return Colors.green;
      case CardType.statusEffect:
        return Colors.purple;
      case CardType.cure:
        return Colors.blue;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!enabled) {
      print('Card is disabled, ignoring tap');
      return;
    }
    print('Card tapped: ${cardData.name} (${cardData.type})');
    onCardPlayed(cardData);
  }

  @override
  bool onTapUp(TapUpEvent event) {
    return enabled;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    return enabled;
  }
}
