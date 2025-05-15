import 'game_card.dart';

class GameCharacter {
  final String name;
  final int maxHealth;
  int currentHealth;
  final int attack;
  final int defense;
  final String emoji;
  final String color;
  final String imagePath;
  final String soundPath;
  final String description;
  final List<GameCard> deck;

  final int maxEnergy;
  int currentEnergy;

  // Mutable combat state
  StatusEffect? statusEffect;
  int? statusDuration;

  List<GameCard> hand = [];
  int handSize;
  List<GameCard> discardPile = [];

  GameCharacter({
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.soundPath,
    required this.description,
    required this.deck,
    this.maxEnergy = 3,
    this.handSize = 5,
  }) : currentHealth = maxHealth,
       currentEnergy = maxEnergy;
} 