import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';

class EquipmentSetupDetailPanel extends BasePanel {
  static const double _buttonWidth = 200.0;
  static const double _buttonHeight = 40.0;
  static const double _buttonSpacing = 16.0;

  String? _selectedSlot;
  EquipmentTemplate? _selectedEquipment;
  SimpleButtonComponent? _equipButton;
  SimpleButtonComponent? _equipDefaultButton;

  EquipmentSetupDetailPanel() : super(size: Vector2(300, 400));

  void updateSelection(String? slot, EquipmentTemplate? equipment) {
    _selectedSlot = slot;
    _selectedEquipment = equipment;
    _updateUI();
  }

  void _updateUI() {
    // Clear existing components
    children.clear();

    if (_selectedSlot == null) {
      // Add a message when no slot is selected
      final textComponent = TextComponent(
        text: 'Select an equipment slot',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        position: Vector2(20, 20),
      );
      add(textComponent);
      return;
    }

    // Add slot name
    final slotText = TextComponent(
      text: _selectedSlot!,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 20),
    );
    add(slotText);

    double yOffset = 60;

    if (_selectedEquipment != null) {
      // Add equipment details
      final nameText = TextComponent(
        text: _selectedEquipment!.name,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        position: Vector2(20, yOffset),
      );
      add(nameText);
      yOffset += 30;

      final descText = TextComponent(
        text: _selectedEquipment!.description,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        position: Vector2(20, yOffset),
      );
      add(descText);
      yOffset += 60;

      // Add cards list
      final cardsText = TextComponent(
        text: 'Cards: ${_selectedEquipment!.cards.join(", ")}',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        position: Vector2(20, yOffset),
      );
      add(cardsText);
      yOffset += 40;
    } else {
      // Add message when no equipment is equipped
      final noEquipText = TextComponent(
        text: 'No equipment equipped',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        position: Vector2(20, yOffset),
      );
      add(noEquipText);
      yOffset += 40;
    }

    // Add buttons
    _equipButton = SimpleButtonComponent.text(
      text: 'Equip Item',
      size: Vector2(_buttonWidth, _buttonHeight),
      color: Colors.blue,
      onPressed: () {
        GameLogger.debug(LogCategory.ui, 'Navigate to inventory scene');
        // TODO: Navigate to inventory scene
      },
      position: Vector2((size.x - _buttonWidth) / 2, yOffset),
    );
    add(_equipButton!);
    yOffset += _buttonHeight + _buttonSpacing;

    _equipDefaultButton = SimpleButtonComponent.text(
      text: 'Equip Default',
      size: Vector2(_buttonWidth, _buttonHeight),
      color: Colors.green,
      onPressed: () {
        if (_selectedSlot == null) return;
        final setup =
            DataController.instance.get<PlayerSetup>('selectedPlayerSetup');
        if (setup == null) return;

        // Find default equipment for this slot
        final slotIndex = setup.template.equipmentSlots.indexOf(_selectedSlot!);
        if (slotIndex == -1 ||
            slotIndex >= setup.template.startingEquipment.length) return;

        final defaultEquipName = setup.template.startingEquipment[slotIndex];
        final defaultEquip = EquipmentTemplate.findByName(defaultEquipName);
        if (defaultEquip == null) return;

        // Update equipment
        setup.equipment[_selectedSlot!] = defaultEquip;
        DataController.instance.set('selectedPlayerSetup', setup);
        GameLogger.debug(
            LogCategory.ui, 'Equipped default equipment: ${defaultEquip.name}');
      },
      position: Vector2((size.x - _buttonWidth) / 2, yOffset),
    );
    add(_equipDefaultButton!);
  }

  @override
  void updateUI() {
    _updateUI();
  }
}
