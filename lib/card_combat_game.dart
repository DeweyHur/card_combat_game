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
import 'package:card_combat_app/components/game_effects.dart';

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
    enemyNextAction = '⚔️ ' + _currentEnemyAction['description'] as String;
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
      final cardVisual = GameEffects.createCardVisual(
        cardData,
        i,
        _gameUI.cardAreaPosition,
        _gameUI.cardAreaSize,
        _executeCard,
        isPlayerTurn,
      );
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
        ],
        onComplete: () {
          remove(effect);
        },
      ),
    );
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
    
    // Play card sound effect
    try {
      _audioPlayer.play(AssetSource('sounds/card_play.mp3'));
    } catch (e) {
      print('Error playing card sound: $e');
    }
    
    // Process card effect
    switch (card.type) {
      case CardType.attack:
        print('Processing attack card: ${card.value} damage');
        enemyHp -= card.value;
        if (enemyHp < 0) enemyHp = 0;
        _gameUI.updateEnemyHp(enemyHp, maxEnemyHp);
        // Play damage effect on enemy
        final damageEffect = GameEffects.createDamageEffect(
          Vector2(_gameUI.enemyAreaPosition.x + _gameUI.enemyAreaSize.x / 2, _gameUI.enemyAreaPosition.y + 40),
          card.value,
          false,
        );
        add(damageEffect);
        break;
      case CardType.heal:
        print('Processing heal card: ${card.value} HP');
        playerHp += card.value;
        if (playerHp > maxPlayerHp) playerHp = maxPlayerHp;
        _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
        // Play heal effect on player
        final healEffect = GameEffects.createHealEffect(
          Vector2(_gameUI.playerAreaPosition.x + _gameUI.playerAreaSize.x / 2, _gameUI.playerAreaPosition.y + 40),
          card.value,
          true,
        );
        add(healEffect);
        break;
      case CardType.statusEffect:
        print('Processing status effect card: ${card.statusEffectToApply}');
        if (card.statusEffectToApply != StatusEffect.none && card.statusDuration != null) {
          _playerStatusEffects[card.statusEffectToApply] = card.statusDuration!;
          _gameUI.updatePlayerStatus(_getStatusText());
          // Show status effect application
          final statusEffect = GameEffects.createStatusEffect(
            Vector2(_gameUI.enemyAreaPosition.x + _gameUI.enemyAreaSize.x / 2, _gameUI.enemyAreaPosition.y + 40),
            card.statusEffectToApply,
            false,
          );
          add(statusEffect);
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
    for (var visual in _cardVisuals) {
      remove(visual);
    }
    _cardVisuals.clear();
    _currentHand.clear();

    // Schedule enemy turn with a delay to allow effects to complete
    Future.delayed(const Duration(milliseconds: 800), () {
      _executeEnemyTurn();
    });
  }

  void _executeEnemyTurn() {
    print('\n=== Enemy Turn ===');
    
    // First, apply DoT effects if any
    _applyDoTEffects().then((_) {
      // Check if enemy is frozen
      if (_playerStatusEffects.containsKey(StatusEffect.freeze)) {
        print('Enemy is frozen! Skipping action.');
        // Show freeze effect
        final freezeEffect = GameEffects.createStatusEffect(
          Vector2(_gameUI.enemyAreaPosition.x + _gameUI.enemyAreaSize.x / 2, _gameUI.enemyAreaPosition.y + 40),
          StatusEffect.freeze,
          false,
        );
        add(freezeEffect);
        
        // Remove freeze effect after it's shown
        _playerStatusEffects.remove(StatusEffect.freeze);
        _gameUI.updatePlayerStatus(_getStatusText());
        
        // Start new player turn after a delay
        Future.delayed(const Duration(milliseconds: 800), () {
          _startNewPlayerTurn();
        });
        return;
      }
      
      // If not frozen, execute normal enemy action
      final damage = _currentEnemyAction['damage'] as int;
      print('Enemy action: ${_currentEnemyAction['name']} for $damage damage');
      
      // Apply enemy action
      playerHp -= damage;
      if (playerHp < 0) playerHp = 0;
      print('Player HP reduced to: $playerHp');
      
      // Play damage effect on player
      final damageEffect = GameEffects.createDamageEffect(
        Vector2(_gameUI.playerAreaPosition.x + _gameUI.playerAreaSize.x / 2, _gameUI.playerAreaPosition.y + 40),
        damage,
        true,
      );
      add(damageEffect);
      
      // Update UI
      _gameUI.updatePlayerHp(playerHp, maxPlayerHp);
      
      // Check for game over
      if (playerHp <= 0) {
        print('Game Over: Player defeated!');
        _gameUI.updateGameInfo('Game Over! You were defeated by the Goblin!');
        return;
      }
      
      // Start new player turn after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        _startNewPlayerTurn();
      });
    });
  }

  Future<void> _applyDoTEffects() async {
    // Update status effect durations and apply damage
    final effectsToApply = Map<StatusEffect, int>.from(_playerStatusEffects);
    
    for (var entry in effectsToApply.entries) {
      final effect = entry.key;
      final duration = entry.value;
      
      // Apply DoT damage if applicable
      if (effect == StatusEffect.poison || effect == StatusEffect.burn) {
        final damage = effect == StatusEffect.poison ? 2 : 3; // Poison does 2 damage, Burn does 3
        enemyHp -= damage;
        if (enemyHp < 0) enemyHp = 0;
        _gameUI.updateEnemyHp(enemyHp, maxEnemyHp);
        
        // Show DoT effect
        final dotEffect = GameEffects.createDoTEffect(
          Vector2(_gameUI.enemyAreaPosition.x + _gameUI.enemyAreaSize.x / 2, _gameUI.enemyAreaPosition.y + 40),
          damage,
          effect,
          false,
        );
        add(dotEffect);
        
        // Wait for the effect to complete
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      final newDuration = duration - 1;
      if (newDuration <= 0) {
        _playerStatusEffects.remove(effect);
      } else {
        _playerStatusEffects[effect] = newDuration;
      }
    }
    
    // Update status text
    _gameUI.updatePlayerStatus(_getStatusText());
  }

  void _startNewPlayerTurn() {
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
        final cardVisual = GameEffects.createCardVisual(
          card,
          i,
          _gameUI.cardAreaPosition,
          _gameUI.cardAreaSize,
          _executeCard,
          isPlayerTurn,
        );
        _cardVisuals.add(cardVisual);
        add(cardVisual);
      }
    }
  }

  String _getStatusText() {
    if (_playerStatusEffects.isEmpty) {
      return '✨ No Status Effects';
    }
    
    final statusStrings = _playerStatusEffects.entries.map((entry) {
      final effect = entry.key;
      final duration = entry.value;
      String effectText = _getStatusEmoji(effect) + ' ' + effect.toString().split('.').last;
      return '$effectText ($duration)';
    }).join(', ');
    
    return '✨ Status: $statusStrings';
  }

  String _getStatusEmoji(StatusEffect effect) {
    switch (effect) {
      case StatusEffect.poison:
        return '☠️';
      case StatusEffect.burn:
        return '🔥';
      case StatusEffect.freeze:
        return '❄️';
      case StatusEffect.none:
        return '✨';
    }
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
