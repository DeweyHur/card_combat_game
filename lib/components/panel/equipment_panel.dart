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

class TapHandler extends PositionComponent with TapCallbacks {
  final String type;
  final Function(String) onTap;

  TapHandler({
    required this.type,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void onTapDown(TapDownEvent event) {
    onTap(type);
  }
}

class EquipmentPanel extends BasePanel {
  EquipmentPanel({Vector2? size}) : super(size: size);

  static const List<String> mainTypes = [
    'Head',
    'Chest',
    'Pants',
    'Shoes',
    'Weapon',
    'Offhand',
    'Belt'
  ];
  static const List<String> accessoryTypes = ['Accessory 1', 'Accessory 2'];

  Map<String, PositionComponent> typeComponents = {};
  Map<String, layout.DataComponent<String>> typeWatchers = {};
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
        // Update all type watchers to new player
        for (final type in typeWatchers.keys) {
          typeWatchers[type]?.setDataKey('equipment:$type');
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
    _buildTypes();
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
        SceneManager().popScene();
      },
      position: Vector2(size.x / 2, size.y - 40),
    ));
  }

  void _buildTypes() {
    typeComponents.clear();
    typeWatchers.clear();
    children.clear();
    final double w = size.x;
    final double h = size.y;
    // Type sizes (smaller proportions)
    final double typeW = w * 0.13;
    final double typeH = h * 0.18;
    final double accW = w * 0.10;
    final double accH = h * 0.12;
    final double centerX = w / 2;
    final double baseY = h * 0.005;
    // Helper to add type and watcher
    void addTypeWithWatcher(String typeLabel, Vector2 pos, Vector2 sz) {
      final typeComp = _buildType(typeLabel, pos, sz);
      typeComponents[typeLabel] = typeComp;
      add(typeComp);
      // Add DataComponent watcher for this type
      final watcher = layout.DataComponent<String>(
        dataKey: 'equipment:$typeLabel',
        onDataChanged: (itemName) {
          // Optionally, update only this type UI if needed
          updateUI();
        },
      );
      typeWatchers[typeLabel] = watcher;
      add(watcher);
    }

    // Head (top center)
    addTypeWithWatcher(
        'Head', Vector2(centerX - typeW / 2, baseY), Vector2(typeW, typeH));
    // Chest (center)
    addTypeWithWatcher(
        'Chest',
        Vector2(centerX - typeW / 2, baseY + typeH + h * 0.01),
        Vector2(typeW, typeH));
    // Belt (above pants)
    addTypeWithWatcher(
        'Belt',
        Vector2(centerX - typeW / 2, baseY + 2 * (typeH + h * 0.01)),
        Vector2(typeW, accH));
    // Pants (below belt)
    addTypeWithWatcher(
        'Pants',
        Vector2(centerX - typeW / 2,
            baseY + 2 * (typeH + h * 0.01) + accH + h * 0.01),
        Vector2(typeW, typeH));
    // Shoes (bottom center)
    addTypeWithWatcher(
        'Shoes',
        Vector2(centerX - typeW / 2, baseY + 4 * (typeH + h * 0.01)),
        Vector2(typeW, accH));
    // Weapon (left of chest)
    addTypeWithWatcher(
        'Weapon',
        Vector2(centerX - typeW - w * 0.08, baseY + typeH + h * 0.01),
        Vector2(typeW, typeH));
    // Offhand (right of chest)
    addTypeWithWatcher(
        'Offhand',
        Vector2(centerX + w * 0.08, baseY + typeH + h * 0.01),
        Vector2(typeW, typeH));
    // Accessory 1 (left of pants)
    addTypeWithWatcher(
        'Accessory 1',
        Vector2(centerX - typeW - w * 0.08, baseY + 2 * (typeH + h * 0.01)),
        Vector2(accW, accH));
    // Accessory 2 (right of pants)
    addTypeWithWatcher(
        'Accessory 2',
        Vector2(centerX + w * 0.08, baseY + 2 * (typeH + h * 0.01)),
        Vector2(accW, accH));
  }

  String getTypeEmoji(String type) {
    switch (type) {
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

  String getTypeDisplayName(String type) {
    if (type == 'Accessory 1') return 'Acc 1';
    if (type == 'Accessory 2') return 'Acc 2';
    return type;
  }

  PositionComponent _buildType(
      String typeLabel, Vector2 position, Vector2 size) {
    final type = PositionComponent(
      position: position,
      size: size,
    );

    // Add background
    type.add(RectangleComponent(
      size: size,
      paint: material.Paint()..color = material.Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add emoji
    type.add(TextComponent(
      text: getTypeEmoji(typeLabel),
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
    type.add(TextComponent(
      text: getTypeDisplayName(typeLabel),
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
    type.add(TapHandler(
      type: typeLabel,
      position: Vector2.zero(),
      size: size,
      onTap: (String type) {
        // Show inventory for this type
        SceneManager().pushScene('inventory', options: {
          'player': currentPlayer,
          'slot': type,
        });
      },
    ));

    return type;
  }

  String? getEquipmentNameForType(String type) {
    if (currentPlayer == null) return null;
    return currentPlayer!.equipment[type];
  }

  @override
  void updateUI() {
    if (currentPlayer == null) return;

    // Update each type component
    for (final type in typeComponents.keys) {
      final equipmentName = getEquipmentNameForType(type);
      final typeComp = typeComponents[type];
      if (typeComp != null) {
        // Update background color based on whether equipment is equipped
        final background = typeComp.children.first as RectangleComponent;
        background.paint.color = equipmentName != null
            ? material.Colors.green.withAlpha(217)
            : material.Colors.black.withAlpha(217);
      }
    }
  }

  void _loadDefaultEquipment() {
    if (currentPlayer == null) return;

    // Clear current equipment
    currentPlayer!.equipment = {};

    // Load default equipment from CSV
    final equipmentData = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');
    if (equipmentData == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] No equipment data found');
      return;
    }

    // Load default equipment for each type
    for (final type in mainTypes) {
      final defaultEquipment = equipmentData.values.firstWhere(
        (e) => e.type.toLowerCase() == type.toLowerCase(),
        orElse: () => EquipmentData(
          name: '',
          type: type,
          description: '',
          rarity: '',
          cards: [],
        ),
      );
      if (defaultEquipment.name.isNotEmpty) {
        currentPlayer!.equip(type, defaultEquipment.name);
      }
    }

    // Load default accessories
    for (final type in accessoryTypes) {
      final defaultEquipment = equipmentData.values.firstWhere(
        (e) => e.type.toLowerCase() == 'accessory',
        orElse: () => EquipmentData(
          name: '',
          type: 'accessory',
          description: '',
          rarity: '',
          cards: [],
        ),
      );
      if (defaultEquipment.name.isNotEmpty) {
        currentPlayer!.equip(type, defaultEquipment.name);
      }
    }

    // Save equipment to preferences
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      prefs.setString('playerEquipment:${currentPlayer!.name}',
          jsonEncode(currentPlayer!.equipment));
    });

    updateUI();
  }
}
