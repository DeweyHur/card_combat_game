import 'package:card_combat_app/components/panel/player_detail_panel.dart';
import 'package:card_combat_app/components/panel/player_selection_panel.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';
import 'package:card_combat_app/components/panel/equipment_detail_panel.dart';
import 'package:card_combat_app/components/panel/equipment_panel.dart';

class ArmorySceneLayout extends PositionComponent
    with TapCallbacks, VerticalStackMixin {
  final GameCharacter player;
  final Map<String, List<EquipmentData>> equipmentByType = {};
  final Map<String, SimpleButtonComponent> typeButtons = {};
  String selectedType = '';
  late final TextComponent _titleText;
  EquipmentDetailPanel? _detailPanel;
  EquipmentPanel? _equipmentPanel;
  Map<String, EquipmentData>? _equipmentData;
  final Map<String, dynamic>? options;

  ArmorySceneLayout({
    required this.player,
    Vector2? position,
    Vector2? size,
    this.options,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Ensure selected player is set in DataController
    final players = DataController.instance.get<List<GameCharacter>>('players');
    final selectedPlayer =
        DataController.instance.get<GameCharacter>('selectedPlayer');
    if ((selectedPlayer == null ||
            (players != null && !players.contains(selectedPlayer))) &&
        players != null &&
        players.isNotEmpty) {
      DataController.instance
          .set<GameCharacter>('selectedPlayer', players.first);
    }
    resetVerticalStack();

    // Title
    _titleText = TextComponent(
      text: 'Armory',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 20),
    );
    registerVerticalStackComponent('title', _titleText, 40);

    // Show PlayerDetailPanel if options contains 'player', else show PlayerSelectionPanel
    if (options != null && options!['player'] != null) {
      final playerDetailPanel = PlayerDetailPanel()
        ..size = Vector2(size.x, size.y * 0.18);
      registerVerticalStackComponent(
          'playerDetailPanel', playerDetailPanel, size.y * 0.18);
    } else {
      final playerSelectionPanel = PlayerSelectionPanel()
        ..size = Vector2(size.x, size.y * 0.18);
      registerVerticalStackComponent(
          'playerSelectionPanel', playerSelectionPanel, size.y * 0.18);
    }

    // Equipment Panel - fill the rest of the space except for detail and back button (60px)
    _equipmentData = DataController.instance
        .get<Map<String, EquipmentData>>('equipmentData');
    final equipmentPanelHeight = size.y - 50 - 60 - (size.y * 0.3);
    _equipmentPanel =
        EquipmentPanel(size: Vector2(size.x, equipmentPanelHeight));
    registerVerticalStackComponent(
        'equipmentPanel', _equipmentPanel!, equipmentPanelHeight);

    // Detail Panel - 30% of height at the bottom
    _detailPanel = EquipmentDetailPanel(
      equipment: EquipmentData(
        name: '',
        type: '',
        description: '',
        rarity: '',
        cards: const [],
      ),
      position: Vector2(0, 0),
      size: Vector2(size.x, size.y * 0.3),
    );
    registerVerticalStackComponent('detailPanel', _detailPanel!, size.y * 0.3);
    hideVerticalStackComponent('detailPanel');

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
  void onMount() {
    super.onMount();
    // Reload the equipment panel when the layout is mounted
    if (_equipmentPanel != null) {
      _equipmentPanel!.updateUI();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    // Optionally, you could re-layout children here if dynamic resizing is needed
  }

  void handleTap(Vector2 pos) {
    // Check if tap is on back button
    final backButton = children.whereType<SimpleButtonComponent>().firstWhere(
          (button) => button.label.text == 'Back',
          orElse: () => SimpleButtonComponent.text(
            text: '',
            size: Vector2.zero(),
            color: Colors.transparent,
            onPressed: () {},
          ),
        );
    if (backButton.label.text == 'Back' &&
        backButton.toRect().contains(pos.toOffset())) {
      SceneManager().popScene();
    }
  }

  void _handleEquipmentSelection(String? equipmentName) {
    if (equipmentName == null || equipmentName.isEmpty) {
      hideVerticalStackComponent('detailPanel');
      return;
    }

    final equipment = _equipmentData?[equipmentName];
    if (equipment == null) {
      GameLogger.error(
          LogCategory.game, '[ARMORY] Equipment not found: $equipmentName');
      return;
    }

    _detailPanel?.updateEquipment(equipment);
    showVerticalStackComponent('detailPanel');
  }

  void _handlePlayerSelection(dynamic value) {
    if (value is GameCharacter) {
      // Update equipment panel
      if (_equipmentPanel != null) {
        _equipmentPanel!.updateUI();
      }
    }
  }
}
