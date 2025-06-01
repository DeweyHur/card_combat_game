import 'package:card_combat_app/components/panel/inventory_grid_cell.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

class InventoryGridPanel extends PositionComponent
    with TapCallbacks, VerticalStackMixin {
  final Function(EquipmentData) onSelect;
  EquipmentDetailPanel? detailPanel;

  late GameCharacter? player;
  late String? slot;
  final int columns;
  final int rows;
  late double cellWidth;
  late double cellHeight;

  InventoryGridPanel({
    required this.onSelect,
    required Vector2 position,
    required Vector2 size,
    this.columns = 3,
    this.rows = 4,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate cell dimensions
    cellWidth = size.x / columns;
    cellHeight = size.y / rows;

    // Get player and slot from scene data
    final player = DataController.instance
        .getSceneData<GameCharacter>('inventory', 'player');
    final slot =
        DataController.instance.getSceneData<String>('inventory', 'slot');

    if (player == null || slot == null) {
      GameLogger.error(
          LogCategory.game, '[INV_GRID] Missing player or slot data');
      return;
    }

    // Create detail panel first
    detailPanel = EquipmentDetailPanel(
      equipment: EquipmentData(
        name: 'Select an item',
        type: '',
        description: '',
        rarity: '',
        cards: [],
      ),
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y * 0.6),
    );
    registerVerticalStackComponent('detail', detailPanel!, size.y * 0.6);

    // Load equipment data
    final equipmentData = await DataController.getEquipmentData();
    if (equipmentData == null) {
      GameLogger.error(
          LogCategory.game, '[INV_GRID] Failed to load equipment data');
      return;
    }

    // Filter equipment for the current slot
    final filteredEquipment = equipmentData.entries.where((entry) {
      final equipment = entry.value;
      return equipment.type.toLowerCase() == slot.toLowerCase();
    }).toList();

    GameLogger.info(LogCategory.game,
        '[INV_GRID] Found ${filteredEquipment.length} items for slot $slot');

    // Create grid cells
    for (var i = 0; i < filteredEquipment.length; i++) {
      final entry = filteredEquipment[i];
      final equipment = entry.value;
      final isEquipped = player.equipment[slot] == equipment.name;

      // Calculate cell position
      final row = i ~/ columns;
      final col = i % columns;
      final cellPosition = Vector2(
        col * cellWidth,
        row * cellHeight,
      );

      final cell = InventoryGridCell(
        equipment: equipment,
        isEquipped: isEquipped,
        onTap: () {
          _updateDetailPanel(equipment);
        },
        position: cellPosition,
        size: Vector2(cellWidth, cellHeight),
      );

      add(cell);
    }
  }

  void _updateDetailPanel(EquipmentData equipment) {
    if (detailPanel != null) {
      detailPanel!.updateEquipment(equipment);
    }
  }
}
