import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:flame/components.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'inventory_panel.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class InventoryPanelContainer extends PositionComponent
    with VerticalStackMixin, TapCallbacks {
  final GameCharacter? player;
  final String? filter;
  final List<EquipmentTemplate> items;
  late final InventoryPanel inventoryPanel;
  void Function(dynamic)? _equipmentWatcher;

  InventoryPanelContainer({
    required this.items,
    required this.filter,
    required this.player,
    required Vector2 size,
  }) : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    inventoryPanel = InventoryPanel(
      size: size,
      filter: filter,
    );
    add(inventoryPanel);

    // Watch for equipment selection
    _equipmentWatcher = (_) {
      final selectedName =
          DataController.instance.get<String>('selectedEquipmentName');
      if (selectedName != null) {
        final equipmentData = DataController.instance
            .get<Map<String, EquipmentTemplate>>('equipmentData');
        if (equipmentData != null) {
          final equipment = equipmentData[selectedName];
          if (equipment != null) {
            _handleItemSelect(equipment);
          }
        }
      }
    };
    DataController.instance.watch('selectedEquipmentName', _equipmentWatcher!);
  }

  @override
  void onRemove() {
    if (_equipmentWatcher != null) {
      DataController.instance
          .unwatch('selectedEquipmentName', _equipmentWatcher!);
    }
    super.onRemove();
  }

  void _handleItemSelect(EquipmentTemplate item) {
    final selectedPlayer =
        DataController.instance.get<PlayerRun>('selectedPlayer');
    if (selectedPlayer != null) {
      selectedPlayer.equip(item.type, item);
      SceneManager().popScene();
    } else {
      GameLogger.error(LogCategory.game, '[INV_CONTAINER] No player selected');
    }
  }
}
