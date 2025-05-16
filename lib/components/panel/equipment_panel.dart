import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/equipment_loader.dart';

class EquipmentPanel extends BasePanel {
  EquipmentPanel({Vector2? size}) : super(size: size);

  static const List<String> mainSlots = [
    'Head', 'Chest', 'Pants', 'Shoes', 'Weapon', 'Offhand', 'Belt'
  ];
  static const List<String> accessorySlots = [
    'Accessory 1', 'Accessory 2'
  ];

  Map<String, PositionComponent> slotComponents = {};
  GameCharacter? currentPlayer;
  Map<String, EquipmentData>? equipmentData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Get equipment data from DataController
    equipmentData = DataController.instance.get<Map<String, EquipmentData>>('equipmentData');
    // Listen for player changes
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is GameCharacter) {
        currentPlayer = value;
        updateUI();
      }
    });
    // Set initial player
    currentPlayer = DataController.instance.get<GameCharacter>('selectedPlayer');
    _buildSlots();
    updateUI();
  }

  void _buildSlots() {
    slotComponents.clear();
    children.clear();
    final double w = size.x;
    final double h = size.y;
    // Slot sizes
    final double slotW = w * 0.16;
    final double slotH = h * 0.28;
    final double accW = w * 0.14;
    final double accH = h * 0.18;
    final double centerX = w / 2;
    final double baseY = h * 0.005;
    // Head (top center)
    slotComponents['Head'] = _buildSlot('Head', Vector2(centerX - slotW / 2, baseY), Vector2(slotW, slotH));
    add(slotComponents['Head']!);
    // Chest (center)
    slotComponents['Chest'] = _buildSlot('Chest', Vector2(centerX - slotW / 2, baseY + slotH + h * 0.01), Vector2(slotW, slotH));
    add(slotComponents['Chest']!);
    // Belt (above pants)
    slotComponents['Belt'] = _buildSlot('Belt', Vector2(centerX - slotW / 2, baseY + 2 * (slotH + h * 0.01)), Vector2(slotW, accH));
    add(slotComponents['Belt']!);
    // Pants (below belt)
    slotComponents['Pants'] = _buildSlot('Pants', Vector2(centerX - slotW / 2, baseY + 2 * (slotH + h * 0.01) + accH + h * 0.01), Vector2(slotW, slotH));
    add(slotComponents['Pants']!);
    // Shoes (bottom center)
    slotComponents['Shoes'] = _buildSlot('Shoes', Vector2(centerX - slotW / 2, baseY + 4 * (slotH + h * 0.01)), Vector2(slotW, accH));
    add(slotComponents['Shoes']!);
    // Weapon (left of chest)
    slotComponents['Weapon'] = _buildSlot('Weapon', Vector2(centerX - slotW - w * 0.08, baseY + slotH + h * 0.01), Vector2(slotW, slotH));
    add(slotComponents['Weapon']!);
    // Offhand (right of chest)
    slotComponents['Offhand'] = _buildSlot('Offhand', Vector2(centerX + w * 0.08, baseY + slotH + h * 0.01), Vector2(slotW, slotH));
    add(slotComponents['Offhand']!);
    // Accessory 1 (left of pants)
    slotComponents['Accessory 1'] = _buildSlot('Accessory 1', Vector2(centerX - slotW - w * 0.08, baseY + 2 * (slotH + h * 0.01)), Vector2(accW, accH));
    add(slotComponents['Accessory 1']!);
    // Accessory 2 (right of pants)
    slotComponents['Accessory 2'] = _buildSlot('Accessory 2', Vector2(centerX + w * 0.08, baseY + 2 * (slotH + h * 0.01)), Vector2(accW, accH));
    add(slotComponents['Accessory 2']!);
  }

  String getSlotEmoji(String slot) {
    switch (slot) {
      case 'Head': return '🪖';
      case 'Chest': return '🦺';
      case 'Belt': return '🪢';
      case 'Pants': return '👖';
      case 'Shoes': return '👢';
      case 'Weapon': return '⚔️';
      case 'Offhand': return '🛡️';
      case 'Accessory 1':
      case 'Accessory 2': return '💍';
      default: return '❓';
    }
  }

  PositionComponent _buildSlot(String label, Vector2 position, Vector2 size) {
    final slot = PositionComponent(
      position: position,
      size: size,
      anchor: Anchor.topLeft,
    );
    slot.add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withOpacity(0.4),
      anchor: Anchor.topLeft,
    ));
    // Add emoji background with opacity
    slot.add(
      TextComponent(
        text: getSlotEmoji(label),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 36,
            color: Colors.white.withOpacity(0.38),
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
        priority: -1, // Render below the label
      ),
    );
    slot.add(
      TextComponent(
        text: label,
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
      // Reset background color
      final bg = slot.children.whereType<RectangleComponent>().firstOrNull;
      if (bg != null) {
        bg.paint.color = Colors.grey.withOpacity(0.4);
      }
    }
    if (currentPlayer == null) return;
    // Get equipment list from player (parse from description or add a field if needed)
    final playerCsv = DataController.instance.get<List<List<dynamic>>>('playersCsv');
    String? equipmentStr;
    if (playerCsv != null) {
      for (final row in playerCsv) {
        if (row.isNotEmpty && row[0] == currentPlayer!.name) {
          if (row.length > 10) {
            equipmentStr = row[10] as String;
          }
          break;
        }
      }
    }
    if (equipmentStr == null) return;
    final equipmentList = equipmentStr.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    // Map slot name to equipment
    final Map<String, String> slotToEquipment = {};
    if (equipmentData != null) {
      for (final eqName in equipmentList) {
        final eq = equipmentData![eqName];
        if (eq != null) {
          String slotKey = _mapEquipmentSlotToPanelSlot(eq.slot, eq.type, eq.name);
          if (slotToEquipment.containsKey(slotKey)) {
            if (slotKey.startsWith('Accessory')) {
              for (final acc in accessorySlots) {
                if (!slotToEquipment.containsKey(acc)) {
                  slotToEquipment[acc] = eqName;
                  break;
                }
              }
            }
            continue;
          }
          slotToEquipment[slotKey] = eqName;
        }
      }
    }
    // Add equipment names to slots and highlight
    slotToEquipment.forEach((slot, eqName) {
      final slotComp = slotComponents[slot];
      if (slotComp != null) {
        // Highlight background
        final bg = slotComp.children.whereType<RectangleComponent>().firstOrNull;
        if (bg != null) {
          bg.paint.color = Colors.amber.withOpacity(0.5);
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
            priority: 1, // So we can remove it later
          ),
        );
      }
    });
  }

  String _mapEquipmentSlotToPanelSlot(String slot, String type, String name) {
    // Map equipment slot/type to UI slot names
    switch (slot) {
      case 'head':
        return 'Head';
      case 'armor':
        if (name.contains('Pants')) return 'Pants';
        if (name.contains('Helmet') || name.contains('Cap')) return 'Head';
        return 'Chest';
      case 'pants':
        return 'Pants';
      case 'shoes':
        return 'Shoes';
      case 'belt':
        return 'Belt';
      case 'weapon':
        return 'Weapon';
      case 'offhand':
        return 'Offhand';
      case 'accessory1':
      case 'accessory2':
      case 'accessory':
        // Find first free accessory slot
        for (final acc in accessorySlots) {
          if (!slotComponents.containsKey(acc)) {
            return acc;
          }
        }
        return 'Accessory 1';
      default:
        return slot;
    }
  }
} 