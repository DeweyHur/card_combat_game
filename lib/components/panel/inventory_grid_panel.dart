import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class InventoryGridPanel extends PositionComponent with TapCallbacks {
  final Function(EquipmentData) onSelect;

  late GameCharacter player;
  late String slot;
  final int columns = 10;
  final int rows = 6;
  late double cellWidth;
  late double cellHeight;

  InventoryGridPanel({
    required this.onSelect,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get player and slot from DataController
    player = DataController.instance.get<GameCharacter>('selectedPlayer')!;
    slot = DataController.instance.get<String>('selectedEquipmentName')!;

    GameLogger.info(
        LogCategory.game, '[INV_GRID] Loading inventory for slot: $slot');
    GameLogger.info(
        LogCategory.game, '[INV_GRID] Current player: ${player.name}');

    // Calculate cell dimensions
    cellWidth = size.x / columns;
    cellHeight = size.y / rows;

    // Add background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Get and filter equipment
    final equipmentMap = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');

    if (equipmentMap == null) {
      GameLogger.error(LogCategory.game, '[INV_GRID] No equipment data found');
      return;
    }

    GameLogger.info(LogCategory.game,
        '[INV_GRID] Total equipment items: ${equipmentMap.length}');

    // Filter equipment for the current slot
    final items = equipmentMap.values.where((e) {
      // Handle accessory slots specially
      if (slot.startsWith('Accessory')) {
        return e.slot.toLowerCase() == 'accessory';
      }
      // For other slots, do exact match
      final matches = e.slot.toLowerCase() == slot.toLowerCase();
      GameLogger.info(LogCategory.game,
          '[INV_GRID] Item ${e.name} slot: ${e.slot}, matches: $matches');
      return matches;
    }).toList();

    GameLogger.info(LogCategory.game,
        '[INV_GRID] Filtered items for slot $slot: ${items.length}');

    // Create grid cells
    for (int i = 0; i < items.length && i < columns * rows; i++) {
      final row = i ~/ columns;
      final col = i % columns;
      final item = items[i];

      final cell = _InventoryCell(
        item: item,
        isSelected: player.equipment[slot] == item.name,
        onTap: () => onSelect(item),
        position: Vector2(col * cellWidth, row * cellHeight),
        size: Vector2(cellWidth, cellHeight),
      );
      add(cell);
    }

    // Select currently equipped item if any
    final equippedItemName = player.equipment[slot];
    if (equippedItemName != null) {
      final equippedItem = items.firstWhere(
        (e) => e.name == equippedItemName,
        orElse: () => items.first,
      );
      onSelect(equippedItem);
    }
  }
}

class _InventoryCell extends PositionComponent with TapCallbacks {
  final EquipmentData item;
  final bool isSelected;
  final VoidCallback onTap;

  _InventoryCell({
    required this.item,
    required this.isSelected,
    required this.onTap,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add cell background
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = isSelected
            ? Colors.blueAccent.withAlpha(217)
            : Colors.white.withAlpha(32),
      anchor: Anchor.topLeft,
    ));

    // Add item name
    add(TextComponent(
      text: item.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
