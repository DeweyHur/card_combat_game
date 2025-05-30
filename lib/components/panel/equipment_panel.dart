import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/components/layout/data_component.dart';
import 'package:card_combat_app/utils/slot_mapper.dart';

class EquipmentPanel extends BasePanel {
  EquipmentPanel({Vector2? size}) : super(size: size);

  static const List<String> mainSlots = [
    'Head',
    'Chest',
    'Pants',
    'Shoes',
    'Weapon',
    'Offhand',
    'Belt'
  ];
  static const List<String> accessorySlots = ['Accessory 1', 'Accessory 2'];

  Map<String, PositionComponent> slotComponents = {};
  Map<String, DataComponent<String>> slotWatchers = {};
  GameCharacter? currentPlayer;
  VoidCallback? _equipmentUnwatch;
  Map<String, EquipmentData>? equipmentData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    equipmentData = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');
    // Listen for player changes
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is GameCharacter) {
        // Unwatch previous player
        _equipmentUnwatch?.call();
        currentPlayer = value;
        // Watch new player's equipment
        currentPlayer!.watch('equipment', (_) => updateUI());
        // Store unwatch callback
        _equipmentUnwatch =
            () => currentPlayer!.unwatch('equipment', (_) => updateUI());
        // Update all slot watchers to new player
        for (final slot in slotWatchers.keys) {
          slotWatchers[slot]?.setDataKey('equipment:$slot');
        }
        updateUI();
      }
    });
    // Set initial player
    currentPlayer =
        DataController.instance.get<GameCharacter>('selectedPlayer');
    if (currentPlayer != null) {
      currentPlayer!.watch('equipment', (_) => updateUI());
      _equipmentUnwatch =
          () => currentPlayer!.unwatch('equipment', (_) => updateUI());
    }
    _buildSlots();
    updateUI();

    // Add Load Defaults button at the bottom
    add(ButtonComponent(
      label: 'Load Defaults',
      color: Colors.green.shade700,
      position: Vector2(size.x / 2 - 70, size.y - 50),
      onPressed: () {
        if (currentPlayer == null) {
          GameLogger.error(
              LogCategory.game, '[EQUIP_PANEL] No current player selected');
          return;
        }
        _loadDefaultEquipment();
      },
    ));
  }

  void _buildSlots() {
    slotComponents.clear();
    slotWatchers.clear();
    children.clear();
    final double w = size.x;
    final double h = size.y;
    // Slot sizes (smaller proportions)
    final double slotW = w * 0.13;
    final double slotH = h * 0.18;
    final double accW = w * 0.10;
    final double accH = h * 0.12;
    final double centerX = w / 2;
    final double baseY = h * 0.005;
    // Helper to add slot and watcher
    void addSlotWithWatcher(String slotLabel, Vector2 pos, Vector2 sz) {
      final slotComp = _buildSlot(slotLabel, pos, sz);
      slotComponents[slotLabel] = slotComp;
      add(slotComp);
      // Add DataComponent watcher for this slot
      final watcher = DataComponent<String>(
        dataKey: 'equipment:$slotLabel',
        onDataChanged: (itemName) {
          // Optionally, update only this slot UI if needed
          updateUI();
        },
      );
      slotWatchers[slotLabel] = watcher;
      add(watcher);
    }

    // Head (top center)
    addSlotWithWatcher(
        'Head', Vector2(centerX - slotW / 2, baseY), Vector2(slotW, slotH));
    // Chest (center)
    addSlotWithWatcher(
        'Chest',
        Vector2(centerX - slotW / 2, baseY + slotH + h * 0.01),
        Vector2(slotW, slotH));
    // Belt (above pants)
    addSlotWithWatcher(
        'Belt',
        Vector2(centerX - slotW / 2, baseY + 2 * (slotH + h * 0.01)),
        Vector2(slotW, accH));
    // Pants (below belt)
    addSlotWithWatcher(
        'Pants',
        Vector2(centerX - slotW / 2,
            baseY + 2 * (slotH + h * 0.01) + accH + h * 0.01),
        Vector2(slotW, slotH));
    // Shoes (bottom center)
    addSlotWithWatcher(
        'Shoes',
        Vector2(centerX - slotW / 2, baseY + 4 * (slotH + h * 0.01)),
        Vector2(slotW, accH));
    // Weapon (left of chest)
    addSlotWithWatcher(
        'Weapon',
        Vector2(centerX - slotW - w * 0.08, baseY + slotH + h * 0.01),
        Vector2(slotW, slotH));
    // Offhand (right of chest)
    addSlotWithWatcher(
        'Offhand',
        Vector2(centerX + w * 0.08, baseY + slotH + h * 0.01),
        Vector2(slotW, slotH));
    // Accessory 1 (left of pants)
    addSlotWithWatcher(
        'Accessory 1',
        Vector2(centerX - slotW - w * 0.08, baseY + 2 * (slotH + h * 0.01)),
        Vector2(accW, accH));
    // Accessory 2 (right of pants)
    addSlotWithWatcher(
        'Accessory 2',
        Vector2(centerX + w * 0.08, baseY + 2 * (slotH + h * 0.01)),
        Vector2(accW, accH));
  }

  String getSlotEmoji(String slot) {
    switch (slot) {
      case 'Head':
        return '🪖';
      case 'Chest':
        return '🦺';
      case 'Belt':
        return '🪢';
      case 'Pants':
        return '👖';
      case 'Shoes':
        return '👢';
      case 'Weapon':
        return '⚔️';
      case 'Offhand':
        return '🛡️';
      case 'Accessory 1':
      case 'Accessory 2':
        return '💍';
      default:
        return '❓';
    }
  }

  String getSlotDisplayName(String slot) {
    if (slot == 'Accessory 1') return 'Acc 1';
    if (slot == 'Accessory 2') return 'Acc 2';
    return slot;
  }

  PositionComponent _buildSlot(String label, Vector2 position, Vector2 size) {
    final slot = _TappableSlot(
      label: label,
      position: position,
      size: size,
      onTap: () {
        final eqName = _getEquipmentNameForSlot(label);
        // Enhanced logging
        GameLogger.info(LogCategory.ui,
            '[EQUIP_PANEL] Slot tapped: $label, Equipment: ${eqName ?? 'empty'}');
        if (eqName != null) {
          DataController.instance.set<String>('selectedEquipmentName', eqName);
        } else {
          DataController.instance.set<String>('selectedEquipmentName', label);
        }
      },
    );
    slot.add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withAlpha(102),
      anchor: Anchor.topLeft,
    ));
    // Add emoji background with opacity
    slot.add(
      TextComponent(
        text: getSlotEmoji(label),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 36,
            color: Colors.white.withAlpha(97),
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
        priority: -1, // Render below the label
      ),
    );
    slot.add(
      TextComponent(
        text: getSlotDisplayName(label),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );
    return slot;
  }

  @override
  void updateUI() {
    // Clear all slot labels and reset backgrounds
    for (final slot in slotComponents.values) {
      slot.children.removeWhere((c) => c is TextComponent && c.priority == 1);
      final bg = slot.children.whereType<RectangleComponent>().firstOrNull;
      if (bg != null) {
        bg.paint.color = Colors.grey.withAlpha(102);
      }
    }
    if (currentPlayer == null) return;
    final slotToEquipment = currentPlayer!.equipment;
    // Add equipment names to slots and highlight
    slotToEquipment.forEach((slot, eqName) {
      final slotComp = slotComponents[slot];
      if (slotComp != null) {
        final bg =
            slotComp.children.whereType<RectangleComponent>().firstOrNull;
        if (bg != null) {
          bg.paint.color = Colors.amber.withAlpha(128);
        }
        slotComp.add(
          TextComponent(
            text: eqName,
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            anchor: Anchor.center,
            position: Vector2(slotComp.size.x / 2, slotComp.size.y / 2 + 18),
            priority: 1,
          ),
        );
      }
    });
  }

  String? _getEquipmentNameForSlot(String slot) {
    if (currentPlayer == null) return null;
    return currentPlayer!.equipment[slot];
  }

  Future<void> _loadDefaultEquipment() async {
    if (currentPlayer == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player selected');
      return;
    }

    final playersCsv = await DataController.getPlayersCsv();
    if (playersCsv == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] Could not load players CSV');
      return;
    }

    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Loading defaults for player: ${currentPlayer!.name}');

    // Find the player's row in the CSV
    final playerRow = playersCsv.firstWhere(
      (row) => row[0] == currentPlayer!.name,
      orElse: () {
        GameLogger.error(LogCategory.game,
            '[EQUIP_PANEL] No matching row found for player: ${currentPlayer!.name}');
        return [];
      },
    );

    if (playerRow.isEmpty) return;

    // Get the default equipment string from column 9 (startingEquipment)
    final defaultEquipmentStr =
        playerRow.length > 9 ? (playerRow[9] as String? ?? '') : '';
    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Default equipment string: $defaultEquipmentStr');

    if (defaultEquipmentStr.isEmpty) {
      GameLogger.error(LogCategory.game,
          '[EQUIP_PANEL] No default equipment found for player: ${currentPlayer!.name}');
      return;
    }

    // Parse the equipment list
    final equipmentList = defaultEquipmentStr
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    GameLogger.info(
        LogCategory.game, '[EQUIP_PANEL] Equipment list: $equipmentList');

    // Get the equipment data
    final equipmentData = await DataController.getEquipmentData();
    if (equipmentData == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] Could not load equipment data');
      return;
    }

    // Get the card data
    final cardData = await DataController.getCardData();
    if (cardData == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] Could not load card data');
      return;
    }

    // Build a mapping of equipment slots to panel slots
    final Map<String, String> slotMapping = {};
    for (final equipmentName in equipmentList) {
      final equipment = equipmentData[equipmentName];
      if (equipment != null) {
        final panelSlot = mapEquipmentSlotToPanelSlot(
            equipment.slot, equipment.type, equipment.name);
        GameLogger.info(LogCategory.game,
            '[EQUIP_PANEL] Mapping equipment: $equipmentName (slot: ${equipment.slot}, type: ${equipment.type}) -> $panelSlot');
        slotMapping[panelSlot] = equipmentName;
      }
    }

    GameLogger.info(
        LogCategory.game, '[EQUIP_PANEL] Final slot mapping: $slotMapping');

    // Update the player's equipment
    currentPlayer!.equipment = slotMapping;

    // Update the player's deck with the cards from the equipment
    final List<GameCard> cardsToAdd = [];
    for (final equipmentName in equipmentList) {
      final equipment = equipmentData[equipmentName];
      if (equipment != null) {
        for (final cardName in equipment.cards) {
          final card = cardData.cardsByName[cardName];
          if (card != null) {
            cardsToAdd.add(card);
          } else {
            GameLogger.error(
                LogCategory.game, '[EQUIP_PANEL] Card not found: $cardName');
          }
        }
      }
    }

    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Cards to add: ${cardsToAdd.map((c) => c.name).toList()}');
    currentPlayer!.setDeck(cardsToAdd);
    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Final deck size: ${currentPlayer!.deck.length}');

    // Notify listeners
    DataController.updateSelectedPlayer(currentPlayer!);
    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Default equipment loaded successfully');
  }
}

class _TappableSlot extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;

  _TappableSlot({
    required this.label,
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
