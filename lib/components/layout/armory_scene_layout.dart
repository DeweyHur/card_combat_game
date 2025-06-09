import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/panel/player_setup_detail_panel.dart';
import 'package:card_combat_app/components/panel/equipment_grid_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/player_setup_selection_panel.dart';
import 'package:card_combat_app/components/panel/equipment_slot_panel.dart';
import 'package:card_combat_app/components/panel/equipment_setup_detail_panel.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

class ArmorySceneLayout extends BasePanel with AreaFillerMixin {
  final PlayerSetup playerSetup;
  final Map<String, dynamic>? options;
  late final PlayerSetupSelectionPanel playerSetupSelectionPanel;
  late final EquipmentSlotPanel equipmentSlotPanel;
  late final EquipmentSetupDetailPanel equipmentSetupDetailPanel;
  late final SimpleButtonComponent backButton;
  dynamic Function(dynamic)? _slotWatcher;

  ArmorySceneLayout({
    required this.playerSetup,
    this.options,
  }) : super(size: Vector2(800, 600));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create player setup selection panel
    playerSetupSelectionPanel = PlayerSetupSelectionPanel();
    registerVerticalStackComponent(
        'playerSetupSelectionPanel', playerSetupSelectionPanel, 100);

    // Create equipment slot panel
    equipmentSlotPanel = EquipmentSlotPanel();
    registerVerticalStackComponent(
        'equipmentSlotPanel', equipmentSlotPanel, 400);

    // Create equipment setup detail panel
    equipmentSetupDetailPanel = EquipmentSetupDetailPanel();
    registerVerticalStackComponent(
        'equipmentSetupDetailPanel', equipmentSetupDetailPanel, 100);

    // Create back button
    backButton = SimpleButtonComponent.text(
      text: 'Back',
      size: Vector2(100, 40),
      color: Colors.red,
      onPressed: () {
        GameLogger.debug(LogCategory.ui, 'Back button pressed');
        SceneManager().popScene();
      },
      position: Vector2(20, 20),
    );
    add(backButton);

    // Watch for slot selection
    _slotWatcher = (_) {
      final selectedSlot = DataController.instance.get<String>('selectedSlot');
      final setup =
          DataController.instance.get<PlayerSetup>('selectedPlayerSetup');
      if (setup != null && selectedSlot != null) {
        final equipment = setup.equipment[selectedSlot];
        equipmentSetupDetailPanel.updateSelection(selectedSlot, equipment);
      }
    };
    DataController.instance.watch('selectedSlot', _slotWatcher!);

    GameLogger.debug(LogCategory.ui, '[ARMORY] Layout loaded successfully');
  }

  @override
  void onRemove() {
    if (_slotWatcher != null) {
      DataController.instance.unwatch('selectedSlot', _slotWatcher!);
    }
    super.onRemove();
  }

  @override
  void updateUI() {
    // Implementation needed
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawAreaFiller(
      canvas,
      colorFromString(playerSetup.template.color).withAlpha(77),
      borderColor: colorFromString(playerSetup.template.color),
      borderWidth: 2.0,
    );
  }
}
