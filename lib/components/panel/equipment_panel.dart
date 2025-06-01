import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/foundation.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/data_component.dart'
    as layout;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class TapHandler extends PositionComponent with TapCallbacks {
  final String slotLabel;
  final Function(String) onTap;

  TapHandler({
    required this.slotLabel,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void onTapDown(TapDownEvent event) {
    onTap(slotLabel);
  }
}

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
  Map<String, layout.DataComponent<String>> slotWatchers = {};
  GameCharacter? currentPlayer;
  VoidCallback? _equipmentUnwatch;
  Map<String, EquipmentData>? equipmentData;
  EquipmentDetailPanel? _detailPanel;

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
    add(SimpleButtonComponent.text(
      text: 'Load Defaults',
      size: Vector2(200, 50),
      color: material.Colors.green.shade700,
      onPressed: () {
        if (currentPlayer == null) {
          GameLogger.error(
              LogCategory.game, '[EQUIP_PANEL] No current player selected');
          return;
        }
        _loadDefaultEquipment();
      },
      position: Vector2(size.x / 2, size.y - 100),
    ));

    add(SimpleButtonComponent.text(
      text: 'Back',
      size: Vector2(200, 50),
      color: material.Colors.blue,
      onPressed: () {
        // ... existing code ...
      },
      position: Vector2(size.x / 2, size.y - 40),
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
      final watcher = layout.DataComponent<String>(
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

  PositionComponent _buildSlot(
      String slotLabel, Vector2 position, Vector2 size) {
    final slot = PositionComponent(
      position: position,
      size: size,
    );

    // Add background
    slot.add(RectangleComponent(
      size: size,
      paint: material.Paint()..color = material.Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add emoji
    slot.add(TextComponent(
      text: getSlotEmoji(slotLabel),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    ));

    // Add label
    slot.add(TextComponent(
      text: getSlotDisplayName(slotLabel),
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 12,
          fontWeight: material.FontWeight.bold,
        ),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y - 4),
    ));

    // Add tap handling
    slot.add(TapHandler(
      slotLabel: slotLabel,
      position: Vector2.zero(),
      size: size,
      onTap: (String slot) {
        final equippedItem = getEquipmentNameForSlot(slot);
        if (equippedItem != null) {
          // Show equipment details panel overlay
          final equipment = equipmentData?[equippedItem];
          if (equipment != null) {
            _showDetailPanel(equipment, slot);
          }
        } else {
          // Show inventory for this slot
          SceneManager().pushScene('inventory', options: {
            'player': currentPlayer,
            'slot': slot,
          });
        }
      },
    ));

    return slot;
  }

  void _showDetailPanel(EquipmentData equipment, String slot) {
    // Remove any existing detail panel
    _detailPanel?.removeFromParent();
    _detailPanel = EquipmentDetailPanel(
      equipment: equipment,
      position: Vector2(size.x / 2 - 150, size.y / 2 - 100),
      size: Vector2(300, 200),
    );
    add(_detailPanel!);
  }

  String? getEquipmentNameForSlot(String slot) {
    if (currentPlayer == null) return null;
    return currentPlayer!.equipment[slot];
  }

  @override
  void updateUI() {
    if (currentPlayer == null) return;

    // Log the current equipment for debugging
    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Player equipment: \\${currentPlayer!.equipment}');

    // Update each slot with its equipped item
    for (final slot in slotComponents.keys) {
      final slotComp = slotComponents[slot];
      if (slotComp != null) {
        // Remove any existing item text
        slotComp.children.removeWhere((child) =>
            child is TextComponent &&
            child.text != getSlotEmoji(slot) &&
            child.text != getSlotDisplayName(slot));

        // Add the equipped item name if there is one
        final equippedItem = getEquipmentNameForSlot(slot);
        if (equippedItem != null) {
          slotComp.add(TextComponent(
            text: equippedItem,
            textRenderer: TextPaint(
              style: const material.TextStyle(
                color: material.Colors.white,
                fontSize: 10,
                fontWeight: material.FontWeight.bold,
              ),
            ),
            anchor: Anchor.topCenter,
            position: Vector2(slotComp.size.x / 2, 4),
          ));
        }
      }
    }
  }

  Future<void> _loadDefaultEquipment() async {
    if (currentPlayer == null) return;

    final playersCsv =
        DataController.instance.get<List<List<dynamic>>>('playersCsv');
    if (playersCsv == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] No players CSV data found');
      return;
    }

    // Find the player's row in the CSV
    final row = playersCsv.firstWhere(
      (r) =>
          r.isNotEmpty &&
          r[0].toString().trim().toLowerCase() ==
              currentPlayer!.name.trim().toLowerCase(),
      orElse: () => [],
    );

    if (row.isEmpty) {
      GameLogger.error(LogCategory.game,
          '[EQUIP_PANEL] No matching row found for player: ${currentPlayer!.name}');
      return;
    }

    // Get default equipment from CSV (column 9)
    final defaultEquipmentStr = row.length > 9 ? (row[9] as String? ?? '') : '';
    if (defaultEquipmentStr.isEmpty) {
      GameLogger.error(LogCategory.game,
          '[EQUIP_PANEL] No default equipment found for player: ${currentPlayer!.name}');
      return;
    }

    // Parse default equipment list
    final defaultEquipmentList = defaultEquipmentStr
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Get equipment data
    final equipmentData = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');
    if (equipmentData == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] No equipment data found');
      return;
    }

    // Create equipment map
    final Map<String, String> equipmentMap = {};
    for (final eqName in defaultEquipmentList) {
      final eq = equipmentData[eqName];
      if (eq != null) {
        equipmentMap[eq.slot] = eqName;
      }
    }

    // Update player's equipment
    currentPlayer!.equipment = equipmentMap;
    DataController.instance.set('selectedPlayer', currentPlayer);

    // Log the current equipment after loading defaults
    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Player equipment after loading defaults: \\${currentPlayer!.equipment}');

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'playerEquipment:${currentPlayer!.name}', jsonEncode(equipmentMap));

    GameLogger.info(LogCategory.game,
        '[EQUIP_PANEL] Loaded default equipment for ${currentPlayer!.name}: $equipmentMap');
  }
}
