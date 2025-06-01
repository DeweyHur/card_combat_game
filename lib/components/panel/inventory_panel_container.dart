import 'package:flame/components.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'inventory_panel.dart';
import 'package:flame/events.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class InventoryPanelContainer extends PositionComponent
    with VerticalStackMixin, TapCallbacks {
  final GameCharacter? player;
  final String? filter;
  final List<EquipmentData> items;
  late final InventoryPanel inventoryPanel;

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
      items: items,
      filter: filter,
      onSelect: _handleItemSelect,
      position: Vector2(0, 0),
      size: size,
    );
    add(inventoryPanel);
  }

  void _handleItemSelect(EquipmentData item) {
    final selectedPlayer =
        DataController.instance.get<GameCharacter>('selectedPlayer');
    if (selectedPlayer != null) {
      selectedPlayer.equip(item.type, item.name);
      SceneManager().popScene();
    }
  }
}
