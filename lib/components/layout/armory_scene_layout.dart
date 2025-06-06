import 'package:flame/components.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/panel/player_setup_detail_panel.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class ArmorySceneLayout extends BasePanel with AreaFillerMixin {
  final PlayerSetup playerSetup;
  late PlayerSetupDetailPanel playerSetupDetailPanel;
  final Map<String, List<EquipmentTemplate>> equipmentByType = {};
  final Map<String, SimpleButtonComponent> typeButtons = {};
  Map<String, EquipmentTemplate>? _equipmentData;
  final Map<String, dynamic>? options;
  static const String _lastSelectedPlayerKey = 'lastSelectedPlayer';

  ArmorySceneLayout({
    required this.playerSetup,
    this.options,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    playerSetupDetailPanel = PlayerSetupDetailPanel();
    playerSetupDetailPanel.updateSetup(playerSetup);
    registerVerticalStackComponent(
        'playerSetupDetailPanel', playerSetupDetailPanel, 80);

    // Load equipment data
    _equipmentData = DataController.instance
        .get<Map<String, EquipmentTemplate>>('equipmentData');
    if (_equipmentData != null) {
      equipmentByType.clear();
      for (final equipment in _equipmentData!.values) {
        equipmentByType.putIfAbsent(equipment.type, () => []).add(equipment);
      }
    }

    // Create type buttons
    for (final type in equipmentByType.keys) {
      final button = SimpleButtonComponent.text(
        text: type,
        size: Vector2(200, 50),
        color: Colors.blue,
        onPressed: () {
          // Handle type selection
        },
      );
      typeButtons[type] = button;
      registerVerticalStackComponent('typeButton_$type', button, 40);
    }

    // Save last selected player
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedPlayerKey, playerSetup.template.name);
  }

  @override
  void updateUI() {
    // Update UI components if needed
    playerSetupDetailPanel.updateSetup(playerSetup);
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
