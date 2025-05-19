import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/components/panel/equipment_panel.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';

class ArmorySceneLayout extends PositionComponent with VerticalStackMixin {
  late final TextComponent _titleText;
  late final PositionComponent _backButton;
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
    registerVerticalStackComponent('titleText', _titleText, 50);

    // Player Selection Panel
    final playerSelectionPanel = PlayerSelectionPanel()
      ..size = Vector2(size.x, size.y * 0.18);
    registerVerticalStackComponent(
        'playerSelectionPanel', playerSelectionPanel, size.y * 0.18);

    // Equipment Panel - fill the rest of the space except for detail and back button (60px)
    _equipmentData = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');
    final equipmentPanelHeight =
        size.y - 50 - (size.y * 0.18) - 60 - (size.y * 0.3);
    _equipmentPanel =
        EquipmentPanel(size: Vector2(size.x, equipmentPanelHeight));
    registerVerticalStackComponent(
        'equipmentPanel', _equipmentPanel!, equipmentPanelHeight);

    // Equipment Detail Panel (initially hidden)
    _detailPanel = EquipmentDetailPanel(
      equipment: EquipmentData(
          name: '', type: '', slot: '', handedness: '', cards: const []),
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y * 0.3),
      onChange: () {
        final selectedPlayer =
            DataController.instance.get<GameCharacter>('selectedPlayer');
        final slot = _detailPanel?.equipment.slot;
        if (selectedPlayer != null && slot != null) {
          SceneManager().pushScene('inventory', options: {
            'player': selectedPlayer,
            'slot': slot,
          });
        }
      },
    );
    registerVerticalStackComponent('detailPanel', _detailPanel!, size.y * 0.3);
    hideVerticalStackComponent('detailPanel');

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
    registerVerticalStackComponent('backButton', _backButton, 60);

    // Listen for equipment selection changes
    DataController.instance.watch('selectedEquipmentName', (value) {
      _handleEquipmentSelection(value as String?);
    });

    // Listen for player selection changes
    DataController.instance.watch('selectedPlayer', (value) {
      _handlePlayerSelection(value);
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    // Optionally, you could re-layout children here if dynamic resizing is needed
  }

  void handleTap(Vector2 pos) {
    if (_backButton.toRect().contains(pos.toOffset())) {
      SceneManager().moveScene('title');
    }
  }

  void _handleEquipmentSelection(String? equipmentName) {
    if (equipmentName == null || equipmentName.isEmpty) {
      hideVerticalStackComponent('detailPanel');
      return;
    }
    if (_equipmentData == null) return;
    final eqData = _equipmentData![equipmentName];
    if (eqData == null) {
      // If equipmentName is a slot label, show empty slot detail
      if (EquipmentPanel.mainSlots.contains(equipmentName) ||
          EquipmentPanel.accessorySlots.contains(equipmentName)) {
        _detailPanel!.updateEquipment(EquipmentData(
          name: 'Empty Slot',
          type: '',
          slot: equipmentName,
          handedness: '',
          cards: const [],
        ));
        showVerticalStackComponent('detailPanel');
      }
      return;
    }
    _detailPanel!.updateEquipment(eqData);
    showVerticalStackComponent('detailPanel');
  }

  void _handlePlayerSelection(dynamic player) {
    // Hide the detail panel if the player changes
    hideVerticalStackComponent('detailPanel');
  }
}
