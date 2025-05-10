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
import 'package:card_combat_app/components/game_ui.dart';

class CardCombatGame extends FlameGame with TapDetector {
  late GameUI _gameUI;
  late List<Card> _cardPool;
  final List<Card> _currentHand = [];
  final List<Component> _cardVisuals = []; // To keep track of card visual components
  final Random _random = Random();

  // Card layout constants
  static const double cardWidth = 100.0;
  static const double cardHeight = 140.0;
  static const double cardSpacing = 0.0;
  static const int maxCards = 3;

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

  // Add status effect tracking
  Map<StatusEffect, int> _playerStatusEffects = {}; // Map of status effect to remaining duration

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> onLoad() async {
    try {
      print('Game initialization started');
      
      // Initialize audio player
      try {
        await _audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
        print('Audio player initialized successfully');
      } catch (e) {
        print('Error initializing audio player: $e');
      }

      // Initialize game UI and wait for it to complete
      _gameUI = GameUI(size);
      await add(_gameUI);  // Wait for GameUI to fully initialize
      print('Game UI initialized');

      // Update initial HP values in UI
      _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
      _gameUI.updateEnemyHp(enemyHp, maxEnemyHp);
      print('Initial HP values set in UI');

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

  void _setNextEnemyAction() {
    _currentEnemyAction = _goblinActions[_random.nextInt(_goblinActions.length)];
    enemyNextAction = _currentEnemyAction['description'];
    _gameUI.updateEnemyAction(enemyNextAction);
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
        style: const TextStyle(
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
        _gameUI.updateEnemyHp(enemyHp, maxEnemyHp);
        // Play damage effect on enemy
        _playDamageEffect(
          Vector2(_gameUI.enemyAreaPosition.x + _gameUI.enemyAreaSize.x / 2, _gameUI.enemyAreaPosition.y + 40),
          false,
        );
        break;
      case CardType.heal:
        print('Processing heal card: ${card.value} HP');
        playerHp += card.value;
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
        break;
      case CardType.statusEffect:
        print('Processing status effect card: ${card.statusEffectToApply}');
        if (card.statusEffectToApply != StatusEffect.none && card.statusDuration != null) {
          _playerStatusEffects[card.statusEffectToApply] = card.statusDuration!;
          _gameUI.updatePlayerStatus(_getStatusText());
        }
        break;
      case CardType.cure:
        print('Processing cure card: ${card.value} HP');
        playerHp += card.value;
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
        // Clear all status effects
        _playerStatusEffects.clear();
        _gameUI.updatePlayerStatus(_getStatusText());
        break;
    }

    // Check for victory
    if (enemyHp <= 0) {
      print('Victory: Enemy defeated!');
      _gameUI.updateGameInfo('Victory! You defeated the Goblin!');
      return;
    }

    // End player turn, start enemy turn
    print('Ending player turn');
    isPlayerTurn = false;
    _gameUI.updateCardAreaText('Enemy Turn');
    
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
    final totalWidth = (maxCards * cardWidth) + ((maxCards - 1) * cardSpacing);
    final startX = (_gameUI.cardAreaSize.x - totalWidth) / 2;

    final position = Vector2(
      _gameUI.cardAreaPosition.x + startX + (index * (cardWidth + cardSpacing)),
      _gameUI.cardAreaPosition.y + (_gameUI.cardAreaSize.y - cardHeight) / 2,
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
      Vector2(_gameUI.playerAreaPosition.x + _gameUI.playerAreaSize.x / 2, _gameUI.playerAreaPosition.y + 40),
      true,
    );
    
    // Update UI
    _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
    
    // Update status effects
    _updateStatusEffects();
    
    // Check for game over
    if (playerHp <= 0) {
      print('Game Over: Player defeated!');
      _gameUI.updateGameInfo('Game Over! You were defeated by the Goblin!');
      return;
    }
    
    // Start new player turn
    print('Starting new player turn...');
    isPlayerTurn = true;
    turnCount++;
    _gameUI.updateTurnText('Turn $turnCount');
    _setNextEnemyAction();
    _gameUI.updateCardAreaText('Your Turn - Choose a Card');
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

  String _getStatusText() {
    if (_playerStatusEffects.isEmpty) {
      return 'No Status Effects';
    }
    
    final statusStrings = _playerStatusEffects.entries.map((entry) {
      final effect = entry.key;
      final duration = entry.value;
      String effectText = effect.toString().split('.').last;
      return '$effectText ($duration)';
    }).join(', ');
    
    return 'Status: $statusStrings';
  }

  void _updateStatusEffects() {
    // Update status effect durations
    _playerStatusEffects = Map.fromEntries(
      _playerStatusEffects.entries.where((entry) {
        final newDuration = entry.value - 1;
        if (newDuration <= 0) {
          return false;
        }
        _playerStatusEffects[entry.key] = newDuration;
        return true;
      })
    );
    
    // Update status text
    _gameUI.updatePlayerStatus(_getStatusText());
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

  static final cardTextStyle = TextPaint(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontFamily: 'monospace',
    ),
  );

  static final cardDescriptionStyle = TextPaint(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontFamily: 'monospace',
    ),
  );

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

    final backgroundPaint = Paint()
      ..color = enabled ? BasicPalette.white.color : BasicPalette.gray.color
      ..style = PaintingStyle.fill;
    final cardBackground = RectangleComponent(
      size: size,
      paint: backgroundPaint,
    );
    add(cardBackground);

    final borderPaint = Paint()
      ..color = _getCardColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final cardBorder = RectangleComponent(
      size: size,
      paint: borderPaint,
    );
    add(cardBorder);

    final nameText = TextComponent(
      text: cardData.name,
      textRenderer: cardTextStyle,
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
    );
    add(nameText);

    final typeText = TextComponent(
      text: cardData.type.toString().split('.').last.toUpperCase(),
      textRenderer: cardDescriptionStyle,
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
    );
    add(typeText);

    final descText = TextComponent(
      text: cardData.description,
      textRenderer: cardDescriptionStyle,
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.bottomCenter,
    );
    add(descText);

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
