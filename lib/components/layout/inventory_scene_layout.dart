import 'package:flame/components.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/components/panel/inventory_grid_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';

class InventorySceneLayout extends PositionComponent {
  late InventoryGridPanel gridPanel;
  late EquipmentDetailPanel detailPanel;
  EquipmentData? selectedEquipment;

  InventorySceneLayout({
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create grid panel
    gridPanel = InventoryGridPanel(
      onSelect: _handleItemSelect,
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y - 220),
    );
    add(gridPanel);

    // Create detail panel (initially hidden)
    detailPanel = EquipmentDetailPanel(
      equipment: EquipmentData(
        name: '',
        type: '',
        slot: '',
        handedness: '',
        cards: [],
      ),
      position: Vector2(0, size.y - 220),
      size: Vector2(size.x, 220),
    );
    detailPanel.removeFromParent();
  }

  void _handleItemSelect(EquipmentData item) {
    selectedEquipment = item;
    detailPanel.updateEquipment(item);
    if (!detailPanel.isMounted) {
      add(detailPanel);
    }
  }
}
