import 'package:flame/components.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'inventory_panel.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flame/events.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'dart:ui' show Paint;

class InventoryPanelContainer extends PositionComponent
    with VerticalStackMixin, TapCallbacks {
  final GameCharacter? player;
  final String? slot;
  final InventoryPanel inventoryPanel;
  SimpleButtonComponent? loadDefaultsButton;

  InventoryPanelContainer({
    required List<EquipmentData> items,
    required String? filter,
    required this.player,
    required this.slot,
    required Vector2 size,
  })  : inventoryPanel = InventoryPanel(
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
            GameLogger.info(LogCategory.game,
                '[INVENTORY] Updating row for player: ${row[0]}');

            // Get both default and current equipment
            String defaultEquipmentStr =
                row.length > 9 ? (row[9] as String? ?? '') : '';
            String currentEquipmentStr =
                row.length > 10 ? (row[10] as String? ?? '') : '';

            GameLogger.info(LogCategory.game,
                '[INVENTORY] Default equipment string: $defaultEquipmentStr');
            GameLogger.info(LogCategory.game,
                '[INVENTORY] Current equipment string: $currentEquipmentStr');

            // Parse both equipment lists
            List<String> defaultEquipmentList = defaultEquipmentStr
                .split('|')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            List<String> currentEquipmentList = currentEquipmentStr
                .split('|')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            GameLogger.info(LogCategory.game,
                '[INVENTORY] Default equipment list: $defaultEquipmentList');
            GameLogger.info(LogCategory.game,
                '[INVENTORY] Current equipment list before update: $currentEquipmentList');

            final equipmentMap = DataController.instance
                    .get<Map<String, EquipmentData>>('equipmentData') ??
                {};

            // Remove any existing equipment in the same slot from current equipment
            currentEquipmentList.removeWhere((eqName) {
              final eq = equipmentMap[eqName];
              return eq != null && eq.slot == slot;
            });

            // Add the new equipment
            currentEquipmentList.add(equipment.name);

            // Update the row
            if (row.length > 10) {
              row[10] = currentEquipmentList.join('|');
            } else {
              while (row.length < 11) {
                row.add('');
              }
              row[10] = currentEquipmentList.join('|');
            }

            GameLogger.info(LogCategory.game,
                '[INVENTORY] Current equipment list after update: $currentEquipmentList');

            // Update the CSV data
            DataController.instance
                .set<List<List<dynamic>>>('playersCsv', playersCsv);

            // Update the player's equipment
            final updatedPlayer = GameCharacter(
              name: row[0] as String,
              maxHealth: int.tryParse(row[1].toString()) ?? 100,
              attack: int.tryParse(row[2].toString()) ?? 10,
              defense: int.tryParse(row[3].toString()) ?? 5,
              emoji: row[4].toString(),
              color: row[5].toString(),
              imagePath: row.length > 6 ? row[6].toString() : '',
              soundPath: row.length > 7 ? row[7].toString() : '',
              description: row.length > 8 ? row[8].toString() : '',
              deck: player.deck,
              maxEnergy: player.maxEnergy,
              handSize: player.handSize,
            );
            DataController.instance
                .set<GameCharacter>('selectedPlayer', updatedPlayer);
          },
          position: Vector2(0, 0),
          size: size,
        ),
        super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add inventory panel
    add(inventoryPanel);

    // Add load defaults button if player is not null
    if (player != null) {
      loadDefaultsButton = SimpleButtonComponent.text(
        text: 'Load Defaults',
        size: Vector2(200, 50),
        color: Colors.blue,
        onPressed: () {
          final playersCsv =
              DataController.instance.get<List<List<dynamic>>>('playersCsv');
          if (playersCsv == null) return;
          final row = playersCsv.firstWhere(
              (r) =>
                  r.isNotEmpty &&
                  r[0].toString().trim().toLowerCase() ==
                      player!.name.trim().toLowerCase(),
              orElse: () => []);
          if (row.isEmpty) return;
          // Get default equipment from CSV
          final defaultEquipmentStr =
              row.length > 9 ? (row[9] as String? ?? '') : '';
          if (row.length > 9) {
            row[9] = defaultEquipmentStr;
          } else {
            while (row.length < 10) {
              row.add('');
            }
            row[9] = defaultEquipmentStr;
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
            maxHealth: int.tryParse(row[1].toString()) ?? 100,
            attack: int.tryParse(row[2].toString()) ?? 10,
            defense: int.tryParse(row[3].toString()) ?? 5,
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
        position: Vector2(size.x / 2, size.y - 40),
      );
      add(loadDefaultsButton!);
    }
  }
}
