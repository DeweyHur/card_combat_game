import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/utils/game_logger.dart';

abstract class PlayerBase extends Character {
  List<GameCard> deck;
  List<GameCard> hand = [];
  List<GameCard> discardPile = [];
  int energy = 0;
  int get maxEnergy;
  String description;

  PlayerBase({
    required super.name,
    required super.maxHealth,
    required super.attack,
    required super.defense,
    required super.emoji,
    required super.color,
    required this.deck,
    required this.description,
  });

  void drawCard() {
    if (deck.isEmpty) {
      if (discardPile.isEmpty) return;
      deck = List.from(discardPile);
      discardPile.clear();
      deck.shuffle();
    }
    hand.add(deck.removeLast());
  }

  void drawInitialHand() {
    for (int i = 0; i < 5; i++) {
      drawCard();
    }
  }

  void playCard(GameCard card) {
    if (!hand.contains(card)) return;
    hand.remove(card);
    discardPile.add(card);
  }

  void endTurn() {
    energy = maxEnergy;
  }

  void startTurn() {
    energy = maxEnergy;
    drawCard();
  }

  void shuffleDeck() {
    deck.shuffle();
  }

  void takeAction(PlayerBase target) {
    final action = getNextAction();
    GameLogger.info(LogCategory.combat, '$name uses ${action.name}');

    switch (action.type) {
      case CardType.attack:
        final damage = calculateDamage(action.value);
        target.takeDamage(damage);
        GameLogger.info(LogCategory.combat, '$name deals $damage damage to ${target.name}');
        break;
      case CardType.statusEffect:
        final effect = action.statusEffectToApply;
        final duration = action.statusDuration;
        if (effect != null && duration != null) {
          target.addStatusEffect(effect, duration);
          GameLogger.info(LogCategory.combat, '$name applies $effect to ${target.name} for $duration turns');
        }
        break;
      case CardType.heal:
        final healAmount = action.value;
        heal(healAmount);
        GameLogger.info(LogCategory.combat, '$name heals for $healAmount');
        break;
      case CardType.cure:
        removeStatusEffect();
        GameLogger.info(LogCategory.combat, '$name removes status effects');
        break;
    }
  }

  int calculateDamage(int baseDamage) {
    return baseDamage;
  }

  @override
  PlayerBase toPlayer() => this;

  @override
  PlayerBase toEnemy() {
    throw UnsupportedError('Player cannot be converted to enemy');
  }
} 