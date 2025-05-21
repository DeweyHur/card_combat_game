import 'package:flame/components.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'inventory_panel.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class InventoryPanelContainer extends PositionComponent
    with VerticalStackMixin {
  InventoryPanelContainer({
    required List<EquipmentData> items,
    required String? filter,
    required GameCharacter? player,
    required String? slot,
    required Vector2 size,
  }) : super(size: size) {
    // Add Load Defaults button if player is not null
    if (player != null) {
      final loadDefaultsButton = ButtonComponent(
        label: 'Load Defaults',
        color: Colors.green.shade700,
        position: Vector2(24, 12),
        onPressed: () {
          final playersCsv =
              DataController.instance.get<List<List<dynamic>>>('playersCsv');
          if (playersCsv == null) return;
          final row = playersCsv.firstWhere(
              (r) =>
                  r.isNotEmpty &&
                  r[0].toString().trim().toLowerCase() ==
                      player.name.trim().toLowerCase(),
              orElse: () => []);
          if (row.isEmpty) return;
          // Get default equipment from CSV
          final defaultEquipmentStr =
              row.length > 10 ? (row[10] as String? ?? '') : '';
          if (row.length > 10) {
            row[10] = defaultEquipmentStr;
          } else {
            while (row.length < 11) {
              row.add('');
            }
            row[10] = defaultEquipmentStr;
          }
          DataController.instance
              .set<List<List<dynamic>>>('playersCsv', playersCsv);
          // Rebuild the GameCharacter from the updated row
          final allCards =
              DataController.instance.get<List<GameCard>>('cards') ?? [];
          final equipmentData = DataController.instance
                  .get<Map<String, EquipmentData>>('equipmentData') ??
              {};
          final updatedEquipmentList = defaultEquipmentStr
              .split('|')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final List<String> cardNames = [];
          for (final eqName in updatedEquipmentList) {
            final eq = equipmentData[eqName];
            if (eq != null) {
              cardNames.addAll(eq.cards);
            }
          }
          final List<GameCard> deck = [];
          for (final cardName in cardNames) {
            final cardIndex = allCards.indexWhere((c) => c.name == cardName);
            if (cardIndex != -1) deck.add(allCards[cardIndex]);
          }
          final updatedPlayer = GameCharacter(
            name: row[0] as String,
            maxHealth: int.parse(row[1].toString()),
            attack: int.parse(row[2].toString()),
            defense: int.parse(row[3].toString()),
            emoji: row[4].toString(),
            color: row[5].toString(),
            imagePath: row.length > 6 ? row[6].toString() : '',
            soundPath: row.length > 7 ? row[7].toString() : '',
            description: row.length > 8 ? row[8].toString() : '',
            deck: deck,
            maxEnergy: 3,
            handSize: row.length > 9 ? int.tryParse(row[9].toString()) ?? 5 : 5,
          );
          DataController.instance
              .set<GameCharacter>('selectedPlayer', updatedPlayer);
        },
      );
      registerVerticalStackComponent(
          'loadDefaultsButton', loadDefaultsButton, 48);
    }
    final panel = InventoryPanel(
      items: items,
      filter: filter,
      onSelect: (equipment) {
        if (player == null || slot == null) return;
        final playersCsv =
            DataController.instance.get<List<List<dynamic>>>('playersCsv');
        if (playersCsv == null) return;
        final row = playersCsv.firstWhere(
            (r) =>
                r.isNotEmpty &&
                r[0].toString().trim().toLowerCase() ==
                    player.name.trim().toLowerCase(),
            orElse: () => []);
        if (row.isEmpty) {
          GameLogger.info(LogCategory.game,
              '[INVENTORY] No matching row found for player: ${player.name}');
          return;
        }
        GameLogger.info(
            LogCategory.game, '[INVENTORY] Updating row for player: ${row[0]}');
        String equipmentStr = row.length > 10 ? (row[10] as String? ?? '') : '';
        List<String> equipmentList = equipmentStr
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final equipmentMap = DataController.instance
                .get<Map<String, EquipmentData>>('equipmentData') ??
            {};
        equipmentList.removeWhere((eqName) {
          final eq = equipmentMap[eqName];
          return eq != null &&
              _mapEquipmentSlotToPanelSlot(eq.slot, eq.type, eq.name) == slot;
        });
        equipmentList.add(equipment.name);
        if (row.length > 10) {
          row[10] = equipmentList.join('|');
        } else {
          while (row.length < 11) {
            row.add('');
          }
          row[10] = equipmentList.join('|');
        }
        DataController.instance
            .set<List<List<dynamic>>>('playersCsv', playersCsv);
        // Rebuild the GameCharacter from the updated row
        final allCards =
            DataController.instance.get<List<GameCard>>('cards') ?? [];
        final equipmentData = DataController.instance
                .get<Map<String, EquipmentData>>('equipmentData') ??
            {};
        final rowIndex = playersCsv.indexOf(row);
        if (rowIndex != -1) {
          final newEquipmentStr = equipmentList.join('|');
          DataController.instance
              .updatePlayersCsvField(rowIndex, 10, newEquipmentStr);
          final updatedRow = playersCsv[rowIndex];
          final name = updatedRow[0] as String;
          final equipmentStr =
              updatedRow.length > 10 ? updatedRow[10] as String : '';
          final updatedEquipmentList = equipmentStr
              .split('|')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final List<String> cardNames = [];
          for (final eqName in updatedEquipmentList) {
            final eq = equipmentData[eqName];
            if (eq != null) {
              cardNames.addAll(eq.cards);
            }
          }
          final List<GameCard> deck = [];
          for (final cardName in cardNames) {
            final cardIndex = allCards.indexWhere((c) => c.name == cardName);
            if (cardIndex != -1) deck.add(allCards[cardIndex]);
          }
          final updatedPlayer = GameCharacter(
            name: name,
            maxHealth: int.parse(updatedRow[1].toString()),
            attack: int.parse(updatedRow[2].toString()),
            defense: int.parse(updatedRow[3].toString()),
            emoji: updatedRow[4].toString(),
            color: updatedRow[5].toString(),
            imagePath: updatedRow.length > 6 ? updatedRow[6].toString() : '',
            soundPath: updatedRow.length > 7 ? updatedRow[7].toString() : '',
            description: updatedRow.length > 8 ? updatedRow[8].toString() : '',
            deck: deck,
            maxEnergy: 3,
            handSize: updatedRow.length > 9
                ? int.tryParse(updatedRow[9].toString()) ?? 5
                : 5,
          );
          GameLogger.info(LogCategory.game,
              '[INVENTORY] Updated player: ${updatedPlayer.name}');
          // Log the Mage row after update
          for (final row in playersCsv) {
            if (row.isNotEmpty &&
                row[0].toString().trim().toLowerCase() == 'mage') {
              GameLogger.info(
                  LogCategory.game, '[INVENTORY] Mage row after update: $row');
            }
          }
          DataController.instance
              .set<GameCharacter>('selectedPlayer', updatedPlayer);
        }
        GameLogger.info(LogCategory.game,
            '[INVENTORY] Selected equipment: ${equipment.name} (slot: ${equipment.slot})');
        SceneManager().popScene();
      },
      size: size,
    );
    registerVerticalStackComponent('inventoryPanel', panel, size.y);
  }

  String _mapEquipmentSlotToPanelSlot(String slot, String type, String name) {
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
        return 'Accessory 1';
      case 'accessory2':
        return 'Accessory 2';
      case 'accessory':
        return 'Accessory 1';
      default:
        return slot;
    }
  }
}
