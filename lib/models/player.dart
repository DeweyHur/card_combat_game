import 'package:card_combat_app/models/card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'equipment.dart';

class Player extends ChangeNotifier {
  int maxHealth;
  int currentHealth;
  int attack;
  int defense;
  String emoji;
  String color;
  String description;
  int maxEnergy;
  int currentEnergy;
  int handSize;
  String special;
  List<String> baseDeck;
  List<String> equipmentSlots;
  List<String> startingEquipment;
  Equipment? weapon;
  Equipment? armor;
  Equipment? accessory;
  List<String> statuses;
  Deck deck;

  Player({
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.emoji,
    required this.color,
    required this.description,
    required this.maxEnergy,
    required this.handSize,
    required this.special,
    required this.baseDeck,
    required this.equipmentSlots,
    required this.startingEquipment,
  })  : currentHealth = maxHealth,
        currentEnergy = maxEnergy,
        statuses = [],
        deck = Deck();

  static Future<Player> loadFromCSV(String className) async {
    final String rawData =
        await rootBundle.loadString('assets/data/players.csv');
    final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

    // Skip header row
    final List<List<dynamic>> data = listData.skip(1).toList();

    // Find the player class data
    final playerData = data.firstWhere(
      (row) => row[0] == className,
      orElse: () => throw Exception('Player class not found: $className'),
    );

    return Player(
      maxHealth: int.parse(playerData[1].toString()),
      attack: int.parse(playerData[2].toString()),
      defense: int.parse(playerData[3].toString()),
      emoji: playerData[4].toString(),
      color: playerData[5].toString(),
      description: playerData[6].toString(),
      maxEnergy: int.parse(playerData[7].toString()),
      handSize: int.parse(playerData[8].toString()),
      special: playerData[9].toString(),
      baseDeck: playerData[10].toString().split('|'),
      equipmentSlots: playerData[11].toString().split('|'),
      startingEquipment: playerData[12].toString().split('|'),
    );
  }

  void takeDamage(int amount) {
    currentHealth = (currentHealth - amount).clamp(0, maxHealth);
  }

  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
  }

  bool isDead() => currentHealth <= 0;

  void addEquipment(Equipment equipment) {
    switch (equipment.slot) {
      case 'weapon':
        weapon = equipment;
        break;
      case 'armor':
        armor = equipment;
        break;
      case 'accessory':
        accessory = equipment;
        break;
    }
    notifyListeners();
  }

  void restoreHealth(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
    notifyListeners();
  }

  void gainEnergy(int amount) {
    currentEnergy = (currentEnergy + amount).clamp(0, maxEnergy);
    notifyListeners();
  }

  void loseEnergy(int amount) {
    currentEnergy = (currentEnergy - amount).clamp(0, maxEnergy);
    notifyListeners();
  }

  void drawCards(int amount) {
    // Implementation depends on your card drawing logic
    notifyListeners();
  }

  void discardCards(int amount) {
    // Implementation depends on your card discarding logic
    notifyListeners();
  }

  void addStatus(String status) {
    statuses.add(status);
    notifyListeners();
  }

  void removeStatus(String status) {
    statuses.remove(status);
    notifyListeners();
  }

  void upgradeEquipment(String slot) {
    // Implementation depends on your equipment upgrade logic
    notifyListeners();
  }

  void downgradeEquipment(String slot) {
    // Implementation depends on your equipment downgrade logic
    notifyListeners();
  }
}

class Deck {
  final List<Card> cards;

  Deck({List<Card>? cards}) : cards = cards ?? [];

  void addCard(Card card) {
    cards.add(card);
  }

  void removeCard(Card card) {
    cards.remove(card);
  }

  void shuffle() {
    cards.shuffle();
  }
}
