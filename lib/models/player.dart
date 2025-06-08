import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/models/game_character.dart'
    show GameCharacter, StatusEffect;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_combat_app/utils/game_logger.dart';
import 'base_models.dart';
import 'name_emoji_interface.dart';
import 'game_character.dart';
import 'card.dart'; // For CardRun, CardTemplate, CardSetup

// Static data loaded from CSV
class PlayerTemplate {
  static List<PlayerTemplate> _templates = [];
  static List<PlayerTemplate> get templates {
    GameLogger.debug(LogCategory.data,
        'Getting player templates, count: ${_templates.length}');
    return _templates;
  }

  final String name;
  final int maxHealth;
  final String emoji;
  final String color;
  final String description;
  final int maxEnergy;
  final int handSize;
  final String special;
  final List<String> equipmentSlots;
  final List<String> startingEquipment;
  final int inventorySize;

  const PlayerTemplate({
    required this.name,
    required this.maxHealth,
    required this.emoji,
    required this.color,
    required this.description,
    required this.maxEnergy,
    required this.handSize,
    required this.special,
    required this.equipmentSlots,
    required this.startingEquipment,
    required this.inventorySize,
  });

  factory PlayerTemplate.fromCsvRow(List<dynamic> row) {
    GameLogger.debug(
        LogCategory.data, 'Creating player template from row: $row');
    // CSV order: name,maxHealth,emoji,color,description,maxEnergy,handSize,special,equipmentSlots,startingEquipment,inventorySize
    try {
      return PlayerTemplate(
        name: row[0].toString().trim(),
        maxHealth: int.parse(row[1].toString().trim()),
        emoji: row[2].toString().trim(),
        color: row[3].toString().trim(),
        description: row[4].toString().trim(),
        maxEnergy: int.parse(row[5].toString().trim()),
        handSize: int.parse(row[6].toString().trim()),
        special: row[7].toString().trim(),
        equipmentSlots: row[8].toString().trim().split(':'),
        startingEquipment: row[9].toString().trim().split('|'),
        inventorySize: int.parse(row[10].toString().trim()),
      );
    } catch (e) {
      GameLogger.error(
          LogCategory.data, 'Error creating player template from row: $e');
      rethrow;
    }
  }

  static Future<List<PlayerTemplate>> loadFromCsv(String assetPath) async {
    GameLogger.debug(
        LogCategory.data, 'Loading player templates from $assetPath');
    final rows = await StaticDataModel.loadCsvData(assetPath);
    GameLogger.debug(LogCategory.data, 'Loaded ${rows.length} rows from CSV');
    _templates = rows.map((row) => PlayerTemplate.fromCsvRow(row)).toList();
    GameLogger.debug(
        LogCategory.data, 'Created ${_templates.length} player templates');
    return _templates;
  }

  static PlayerTemplate? findByName(String name) {
    return StaticDataModel.find<PlayerTemplate>(_templates, 'name', name);
  }

  static PlayerTemplate? findBySpecial(String special) {
    return StaticDataModel.find<PlayerTemplate>(_templates, 'special', special);
  }
}

// Local setup data for equipment configuration
class PlayerSetup implements NameEmojiInterface {
  final PlayerTemplate template;
  final Map<String, EquipmentTemplate> equipment = {};

  PlayerSetup(this.template) {
    // Initialize equipment from template
    final equipmentNames = template.startingEquipment;
    final slots = template.equipmentSlots;

    // Ensure we don't exceed array bounds
    final count = equipmentNames.length < slots.length
        ? equipmentNames.length
        : slots.length;

    for (var i = 0; i < count; i++) {
      final slot = slots[i];
      final equipmentName = equipmentNames[i];
      final equipment = EquipmentTemplate.findByName(equipmentName);
      if (equipment != null) {
        this.equipment[slot] = equipment;
      } else {
        GameLogger.error(
            LogCategory.data, 'Error finding equipment: $equipmentName');
      }
    }
  }

  @override
  String get name => template.name;

  @override
  String get emoji => template.emoji;

  void equip(String type, EquipmentTemplate item) {
    if (!template.equipmentSlots.contains(type)) {
      GameLogger.error(LogCategory.game, 'Invalid equipment type: $type');
      return;
    }
    equipment[type] = item;
    saveToLocalStorage();
  }

  void unequip(String type) {
    equipment.remove(type);
    saveToLocalStorage();
  }

  @override
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'template': template.name,
      'equipment': equipment.map((type, item) => MapEntry(type, item.name)),
    };
    await prefs.setString('playerEquipment:${template.name}', jsonEncode(data));
  }

  @override
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('playerEquipment:${template.name}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        final equipmentData = data['equipment'] as Map<String, dynamic>;
        equipmentData.forEach((type, name) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            equipment[type] = item;
          }
        });
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading saved data: $e');
      }
    }
  }
}

// Active player state during a run
class PlayerRun extends GameCharacter
    implements RunDataModel, NameEmojiInterface {
  final PlayerSetup setup;
  final List<CardRun> deck = [];
  final List<CardRun> hand = [];
  final List<CardRun> discardPile = [];

  // Non-common data moved from GameCharacter
  @override
  final String name;
  @override
  final String emoji;
  final String color;
  final String description;
  final int maxEnergy;
  final int handSize;
  int _currentEnergy;
  int get currentEnergy => _currentEnergy;
  set currentEnergy(int value) {
    if (_currentEnergy != value) {
      _currentEnergy = value.clamp(0, maxEnergy);
      notifyListeners();
    }
  }

  // Stats
  int _wins = 0;
  int get wins => _wins;
  set wins(int value) {
    if (_wins != value) {
      _wins = value;
      notifyListeners();
    }
  }

  // Equipment management
  final Map<String, EquipmentTemplate> _equipment = {};
  Map<String, EquipmentTemplate> get equipment => Map.unmodifiable(_equipment);

  // Inventory management
  final List<EquipmentTemplate> _inventory = [];
  List<EquipmentTemplate> get inventory => List.unmodifiable(_inventory);
  int get inventorySize => setup.template.inventorySize;
  int get inventorySpaceRemaining => inventorySize - _inventory.length;

  PlayerRun(this.setup)
      : name = setup.template.name,
        emoji = setup.template.emoji,
        color = setup.template.color,
        description = setup.template.description,
        maxEnergy = setup.template.maxEnergy,
        handSize = setup.template.handSize,
        _currentEnergy = setup.template.maxEnergy,
        super(maxHealth: setup.template.maxHealth) {
    // Initialize equipment from setup
    _equipment.addAll(setup.equipment);
    buildDeck();
  }

  // Inventory management methods
  bool addToInventory(EquipmentTemplate item) {
    if (_inventory.length >= inventorySize) {
      GameLogger.error(LogCategory.game, 'Inventory is full');
      return false;
    }
    _inventory.add(item);
    notifyListeners();
    return true;
  }

  bool removeFromInventory(EquipmentTemplate item) {
    final removed = _inventory.remove(item);
    if (removed) {
      notifyListeners();
    }
    return removed;
  }

  void equip(String type, EquipmentTemplate item) {
    if (!setup.template.equipmentSlots.contains(type)) {
      GameLogger.error(LogCategory.game, 'Invalid equipment type: $type');
      return;
    }
    if (!_inventory.contains(item)) {
      GameLogger.error(LogCategory.game, 'Item not in inventory');
      return;
    }
    // Unequip current item if any
    final currentItem = _equipment[type];
    if (currentItem != null) {
      _inventory.add(currentItem);
    }
    // Equip new item
    _equipment[type] = item;
    _inventory.remove(item);
    buildDeck(); // Rebuild deck when equipment changes
    notifyListeners();
  }

  void unequip(String type) {
    if (_equipment.containsKey(type)) {
      final item = _equipment[type]!;
      if (_inventory.length >= inventorySize) {
        GameLogger.error(LogCategory.game, 'Cannot unequip: inventory is full');
        return;
      }
      _equipment.remove(type);
      _inventory.add(item);
      buildDeck(); // Rebuild deck when equipment changes
      notifyListeners();
    }
  }

  void buildDeck() {
    deck.clear();
    // Add cards from equipped items
    for (final equipment in _equipment.values) {
      for (final cardName in equipment.cards) {
        final cardTemplate = CardTemplate.findByName(cardName.trim());
        if (cardTemplate != null) {
          final cardSetup = CardSetup(cardTemplate);
          final card = CardRun(cardSetup);
          deck.add(card);
        }
      }
    }
    // Shuffle the deck
    deck.shuffle();
  }

  void drawCards(int count) {
    for (int i = 0; i < count && deck.isNotEmpty; i++) {
      if (hand.length < handSize) {
        hand.add(deck.removeLast());
      }
    }
    notifyListeners();
  }

  void discardCards(int count) {
    for (int i = 0; i < count && hand.isNotEmpty; i++) {
      discardPile.add(hand.removeLast());
    }
    notifyListeners();
  }

  void gainEnergy(int amount) {
    currentEnergy = (currentEnergy + amount).clamp(0, maxEnergy);
    GameLogger.info(LogCategory.combat,
        '$name gains $amount energy. Energy: $currentEnergy/$maxEnergy');
  }

  void loseEnergy(int amount) {
    currentEnergy = (currentEnergy - amount).clamp(0, maxEnergy);
    GameLogger.info(LogCategory.combat,
        '$name loses $amount energy. Energy: $currentEnergy/$maxEnergy');
  }

  void startTurn() {
    currentEnergy = maxEnergy;
    GameLogger.info(
        LogCategory.combat, '$name starts turn with $currentEnergy energy');
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'currentHealth': currentHealth,
        'currentEnergy': _currentEnergy,
        'wins': _wins,
        'equipment':
            _equipment.map((type, item) => MapEntry(type, item.toJson())),
        'inventory': _inventory.map((item) => item.toJson()).toList(),
        'statusEffects': statusEffects.map(
          (type, count) => MapEntry(type.toString().split('.').last, count),
        ),
      };

  @override
  Future<void> saveRunData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'playerRun:${setup.template.name}', jsonEncode(toJson()));
  }

  @override
  Future<void> loadRunData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('playerRun:${setup.template.name}');
    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        currentHealth = data['currentHealth'] as int;
        _currentEnergy = data['currentEnergy'] as int;
        _wins = data['wins'] as int? ?? 0;

        // Load equipment
        _equipment.clear();
        final equipmentData = data['equipment'] as Map<String, dynamic>;
        equipmentData.forEach((type, name) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            _equipment[type] = item;
          }
        });

        // Load inventory
        _inventory.clear();
        final inventoryData = data['inventory'] as List<dynamic>;
        for (final name in inventoryData) {
          final item = EquipmentTemplate.findByName(name as String);
          if (item != null) {
            _inventory.add(item);
          }
        }

        // Load status effects
        statusEffects.clear();
        final effects = data['statusEffects'] as List<dynamic>;
        for (final effect in effects) {
          final type = StatusEffect.values.firstWhere(
            (e) => e.toString().split('.').last == effect['type'],
            orElse: () => StatusEffect.none,
          );
          if (type != StatusEffect.none) {
            statusEffects[type] = effect['count'] as int;
          }
        }

        buildDeck(); // Rebuild deck after loading equipment
        notifyListeners();
      } catch (e) {
        GameLogger.error(LogCategory.data, 'Error loading run data: $e');
      }
    }
  }

  @override
  void reset() {
    currentHealth = maxHealth;
    currentEnergy = maxEnergy;
    deck.clear();
    hand.clear();
    discardPile.clear();
    statusEffects.clear();
    _equipment.clear();
    _inventory.clear();
    _equipment.addAll(setup.equipment); // Reset to starting equipment
    buildDeck();
    notifyListeners();
  }
}
