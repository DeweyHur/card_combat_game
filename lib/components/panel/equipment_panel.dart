import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/foundation.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/data_component.dart'
    as layout;
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'dart:ui' show Paint, PaintingStyle;
import 'package:card_combat_app/models/player.dart';

class EquipmentTapHandler extends PositionComponent with TapCallbacks {
  final String typeLabel;
  final PlayerRun? currentPlayer;

  EquipmentTapHandler({
    required this.typeLabel,
    required this.currentPlayer,
    required Vector2 size,
  }) : super(size: size);

  @override
  void onTapDown(TapDownEvent event) {
    if (currentPlayer == null) {
      GameLogger.error(
          LogCategory.game, '[EQUIP_PANEL] No current player selected');
      return;
    }
    final equipment = currentPlayer!.equipment[typeLabel];
    if (equipment != null) {
      DataController.instance.set('selectedEquipmentName', equipment.name);
    }
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
  PlayerRun? currentPlayer;
  VoidCallback? _equipmentUnwatch;
  Map<String, EquipmentTemplate>? equipmentData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    equipmentData = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
    // Listen for player changes
    DataController.instance.watch('selectedPlayer', (value) {
      if (value is PlayerRun) {
        // Unwatch previous player
        _equipmentUnwatch?.call();
        currentPlayer = value;
        // Watch new player's equipment using nested path
        DataController.instance
            .watch('selectedPlayer.equipment', (_) => updateUI());
        // Store unwatch callback
        _equipmentUnwatch = () => DataController.instance
            .unwatch('selectedPlayer.equipment', (_) => updateUI());
        // Update all type watchers to new player
        for (final type in typeWatchers.keys) {
          typeWatchers[type]?.setDataKey('selectedPlayer.equipment:$type');
        }
        updateUI();
      }
    });
    // Set initial player
    currentPlayer = DataController.instance.get<PlayerRun>('selectedPlayer');
    if (currentPlayer != null) {
      DataController.instance
          .watch('selectedPlayer.equipment', (_) => updateUI());
      _equipmentUnwatch = () => DataController.instance
          .unwatch('selectedPlayer.equipment', (_) => updateUI());
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
        dataKey: 'selectedPlayer.equipment:$typeLabel',
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
    // Belt (below chest)
    addTypeWithWatcher(
        'Belt',
        Vector2(centerX - typeW / 2, baseY + 2 * typeH + h * 0.02),
        Vector2(typeW, typeH));
    // Pants (below belt)
    addTypeWithWatcher(
        'Pants',
        Vector2(centerX - typeW / 2, baseY + 3 * typeH + h * 0.03),
        Vector2(typeW, typeH));
    // Shoes (bottom)
    addTypeWithWatcher(
        'Shoes',
        Vector2(centerX - typeW / 2, baseY + 4 * typeH + h * 0.04),
        Vector2(typeW, typeH));
    // Weapon (right side)
    addTypeWithWatcher(
        'Weapon',
        Vector2(centerX + typeW + w * 0.01, baseY + typeH),
        Vector2(typeW, typeH));
    // Offhand (right side, below weapon)
    addTypeWithWatcher(
        'Offhand',
        Vector2(centerX + typeW + w * 0.01, baseY + 2 * typeH + h * 0.01),
        Vector2(typeW, typeH));
    // Accessory 1 (right side, below offhand)
    addTypeWithWatcher(
        'Accessory 1',
        Vector2(centerX + typeW + w * 0.01, baseY + 3 * typeH + h * 0.02),
        Vector2(accW, accH));
    // Accessory 2 (right side, below accessory 1)
    addTypeWithWatcher(
        'Accessory 2',
        Vector2(
            centerX + typeW + w * 0.01, baseY + 3 * typeH + accH + h * 0.03),
        Vector2(accW, accH));
  }

  PositionComponent _buildType(
      String typeLabel, Vector2 position, Vector2 size) {
    final component = PositionComponent(
      position: position,
      size: size,
    );

    // Background
    component.add(RectangleComponent(
      size: size,
      paint: Paint()..color = material.Colors.black.withAlpha(77),
    ));

    // Border
    component.add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = material.Colors.white.withAlpha(77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    ));

    // Label
    component.add(TextComponent(
      text: typeLabel,
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 16,
          fontWeight: material.FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));

    // Add tap handler
    component.add(EquipmentTapHandler(
      typeLabel: typeLabel,
      currentPlayer: currentPlayer,
      size: size,
    ));

    return component;
  }

  @override
  void updateUI() {
    if (currentPlayer == null) return;

    // Update all type components
    for (final entry in typeComponents.entries) {
      final type = entry.key;
      final component = entry.value;
      final equipment = currentPlayer!.equipment[type];
      if (equipment != null) {
        // Update component appearance for equipped item
        component.children.whereType<RectangleComponent>().forEach((rect) {
          if (rect.paint.style == PaintingStyle.fill) {
            rect.paint.color = material.Colors.green.withAlpha(77);
          }
        });
      } else {
        // Reset component appearance
        component.children.whereType<RectangleComponent>().forEach((rect) {
          if (rect.paint.style == PaintingStyle.fill) {
            rect.paint.color = material.Colors.black.withAlpha(77);
          }
        });
      }
    }
  }

  void _loadDefaultEquipment() {
    if (currentPlayer == null || equipmentData == null) return;

    // Load default equipment for each slot
    for (final type in [...mainTypes, ...accessoryTypes]) {
      final defaultEquipment = equipmentData!.values
          .firstWhere((eq) => eq.type == type && eq.rarity == 'Common');
      if (defaultEquipment.name.isNotEmpty) {
        currentPlayer!.equip(type, defaultEquipment);
      }
    }
  }
}
