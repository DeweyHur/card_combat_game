import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/components/panel/inventory_grid_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

class InventorySceneLayout extends PositionComponent
    with TapCallbacks, VerticalStackMixin {
  late InventoryGridPanel gridPanel;
  late EquipmentDetailPanel detailPanel;
  late SimpleButtonComponent backButton;
  EquipmentData? selectedEquipment;

  InventorySceneLayout({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create back button
    backButton = SimpleButtonComponent.text(
      text: 'Back',
      size: Vector2(100, 40),
      color: Colors.grey.shade800,
      onPressed: () {
        SceneManager().popScene();
      },
    );
    registerVerticalStackComponent('back_button', backButton, 40);

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
    registerVerticalStackComponent('detail', detailPanel, 220);
    hideVerticalStackComponent('detail');

    // Create grid panel
    gridPanel = InventoryGridPanel(
      onSelect: _handleItemSelect,
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y - 280),
    );
    registerVerticalStackComponent('grid', gridPanel, size.y - 280);
  }

  void _handleItemSelect(EquipmentData item) {
    selectedEquipment = item;
    detailPanel.updateEquipment(item);
    showVerticalStackComponent('detail');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (backButton.toRect().contains(event.localPosition.toOffset())) {
      SceneManager().popScene();
    }
  }
}
