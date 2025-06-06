import 'package:card_combat_app/models/equipment.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/components/panel/inventory_list_panel.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class InventorySceneLayout extends PositionComponent with VerticalStackMixin {
  final PlayerSetup player;
  final String slot;

  InventorySceneLayout({
    required this.player,
    required this.slot,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();

    // Add background
    final background = RectangleComponent(
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    registerVerticalBackgroundComponent('background', background);

    // Add detail panel
    final detailPanel = EquipmentDetailPanel();
    registerVerticalStackComponent('detail_panel', detailPanel, 200);

    // Add list panel
    final listPanel = InventoryListPanel(
      slot: slot,
      onSelect: (EquipmentTemplate equipment) {
        detailPanel.updateEquipment(equipment);
      },
    );
    registerVerticalStackComponent('list_panel', listPanel, size.y - 270);

    // Add back button
    final backButton = SimpleButtonComponent(
      label: TextComponent(
        text: 'Back',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      button: RectangleComponent(
        paint: Paint()..color = Colors.blue,
      ),
      onPressed: () {
        SceneManager().popScene();
      },
    );
    registerVerticalStackComponent('back_button', backButton, 40);
  }
}
