import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/equipment_panel.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/equipment_loader.dart';

class ArmorySceneLayout extends PositionComponent with VerticalStackMixin {
  late final TextComponent _titleText;
  late final PositionComponent _backButton;
  bool _isLoaded = false;
  EquipmentDetailPanel? _detailPanel;
  EquipmentPanel? _equipmentPanel;
  Map<String, EquipmentData>? _equipmentData;

  ArmorySceneLayout();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();

    // Title
    _titleText = TextComponent(
      text: 'Armory / Equipment',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      size: Vector2(size.x, 50),
    );
    addToVerticalStack(_titleText, 50);

    // Player Selection Panel
    final playerSelectionPanel = PlayerSelectionPanel()
      ..size = Vector2(size.x, size.y * 0.18);
    addToVerticalStack(playerSelectionPanel, size.y * 0.18);

    // Equipment Panel - fill the rest of the space except for detail and back button (60px)
    _equipmentData = DataController.instance.get<Map<String, EquipmentData>>('equipmentData');
    final equipmentPanelHeight = size.y - 50 - (size.y * 0.18) - 60 - (size.y * 0.3);
    _equipmentPanel = EquipmentPanel(size: Vector2(size.x, equipmentPanelHeight));
    addToVerticalStack(_equipmentPanel!, equipmentPanelHeight);

    // Equipment Detail Panel (initially hidden)
    _detailPanel = null;
    // Do not add a placeholder; detail panel will be added dynamically

    // Back Button
    _backButton = PositionComponent(
      size: Vector2(160, 48),
      anchor: Anchor.topCenter,
    )
      ..add(RectangleComponent(
        size: Vector2(160, 48),
        paint: Paint()..color = Colors.grey.shade800,
        anchor: Anchor.topLeft,
      ))
      ..add(
        TextComponent(
          text: 'Back',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(80, 24),
        ),
      );
    addToVerticalStack(_backButton, 60);

    // Listen for equipment selection changes
    DataController.instance.watch('selectedEquipmentName', (value) {
      _showDetailPanel(value as String?);
    });

    _isLoaded = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    // Optionally, you could re-layout children here if dynamic resizing is needed
  }

  void handleTap(Vector2 pos) {
    if (_backButton.toRect().contains(pos.toOffset())) {
      SceneManager().pushScene('title');
    }
  }

  void _showDetailPanel(String? equipmentName) {
    // Remove previous detail panel
    if (_detailPanel != null) {
      _detailPanel!.removeFromParent();
      _detailPanel = null;
    }
    if (equipmentName == null || equipmentName.isEmpty || _equipmentData == null) {
      return;
    }
    final eqData = _equipmentData![equipmentName];
    if (eqData == null) return;
    _detailPanel = EquipmentDetailPanel(
      equipment: eqData,
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y * 0.3),
      onChange: () {},
      onUnequip: () {},
    );
    addToVerticalStack(_detailPanel!, size.y * 0.3);
  }
} 