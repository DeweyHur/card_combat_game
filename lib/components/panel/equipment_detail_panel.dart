import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/multiline_text_component.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';

class EquipmentDetailPanel extends BasePanel {
  EquipmentTemplate? _equipment;
  late MultilineTextComponent _nameText;
  late MultilineTextComponent _descriptionText;
  late MultilineTextComponent _cardsText;
  SimpleButtonComponent? _equipButton;
  static const double _padding = 20;

  EquipmentDetailPanel() : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game,
        '[EQUIP_PANEL] Panel loading for equipment: ${_equipment?.name}');

    // Add equipment details
    final player = DataController.instance.get<PlayerRun>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }
    GameLogger.debug(
        LogCategory.game, '[EQUIP_PANEL] Selected player: ${player.name}');

    final isEquipped = player.equipment[_equipment?.type] == _equipment;
    GameLogger.debug(LogCategory.game,
        '[EQUIP_PANEL] Equipment type: ${_equipment?.type}, isEquipped: $isEquipped');

    _nameText = MultilineTextComponent(
      text: '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      maxWidth: size.x - (_padding * 2),
    );
    registerVerticalStackComponent('nameText', _nameText, 40);

    _descriptionText = MultilineTextComponent(
      text: '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      maxWidth: size.x - (_padding * 2),
    );
    registerVerticalStackComponent('descriptionText', _descriptionText, 80);

    _cardsText = MultilineTextComponent(
      text: '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      maxWidth: size.x - (_padding * 2),
    );
    registerVerticalStackComponent('cardsText', _cardsText, 60);

    _createEquipButton();
  }

  void _createEquipButton() {
    // Remove old button if it exists
    if (_equipButton != null) {
      _equipButton!.removeFromParent();
      hideVerticalStackComponent('equipButton');
    }

    // Create new button
    _equipButton = SimpleButtonComponent.text(
      text: _equipment != null ? 'Equip' : '',
      size: Vector2(120, 40),
      color: Colors.blue,
      onPressed: _equipment != null ? _handleEquip : null,
    );
    registerVerticalStackComponent('equipButton', _equipButton!, 40);
  }

  void updateEquipment(EquipmentTemplate equipment) {
    _equipment = equipment;
    _updateUI();
  }

  void _updateUI() {
    if (_equipment != null) {
      _nameText.text = '${_equipment!.name} (${_equipment!.rarity})';
      _descriptionText.text = _equipment!.description;
      _cardsText.text = 'Cards: ${_equipment!.cards.join(", ")}';
    } else {
      _nameText.text = '';
      _descriptionText.text = '';
      _cardsText.text = '';
    }
    _createEquipButton();
  }

  void _handleEquip() {
    if (_equipment != null) {
      // TODO: Implement equip logic
      GameLogger.info(
          LogCategory.ui, '[ARMORY] Equipping: ${_equipment!.name}');
    }
  }

  @override
  void updateUI() {
    _updateUI();
  }
}
