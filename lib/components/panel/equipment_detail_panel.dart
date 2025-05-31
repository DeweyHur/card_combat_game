import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class EquipmentDetailPanel extends PositionComponent with TapCallbacks {
  EquipmentData equipment;
  SimpleButtonComponent? actionButton;
  SimpleButtonComponent? inventoryButton;

  EquipmentDetailPanel({
    required this.equipment,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    ));

    // Add equipment details
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }

    final isEquipped = player.equipment[equipment.slot] == equipment.name;

    // Add name
    add(TextComponent(
      text: equipment.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 20),
    ));

    // Add type
    add(TextComponent(
      text: 'Type: ${equipment.type}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 60),
    ));

    // Add slot
    add(TextComponent(
      text: 'Slot: ${equipment.slot}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 90),
    ));

    // Add handedness if not empty
    if (equipment.handedness.isNotEmpty) {
      add(TextComponent(
        text: 'Handedness: ${equipment.handedness}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        anchor: Anchor.topLeft,
        position: Vector2(20, 120),
      ));
    }

    // Add cards if any
    if (equipment.cards.isNotEmpty) {
      add(TextComponent(
        text: 'Cards:',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.topLeft,
        position: Vector2(20, 150),
      ));

      for (int i = 0; i < equipment.cards.length; i++) {
        add(TextComponent(
          text: '• ${equipment.cards[i]}',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          anchor: Anchor.topLeft,
          position: Vector2(40, 180 + i * 25),
        ));
      }
    }

    // Add action buttons
    _updateActionButtons(isEquipped);
    _addInventoryButton();
  }

  void _updateActionButtons(bool isEquipped) {
    // Remove existing button if any
    actionButton?.removeFromParent();

    // Create new button
    actionButton = SimpleButtonComponent.text(
      text: isEquipped ? 'Unequip' : 'Equip',
      size: Vector2(200, 50),
      color: isEquipped ? Colors.red : Colors.green,
      onPressed: () {
        final player =
            DataController.instance.get<GameCharacter>('selectedPlayer');
        if (player == null) {
          GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
          return;
        }

        if (isEquipped) {
          player.unequip(equipment.slot);
        } else {
          player.equip(equipment.slot, equipment.name);
        }

        DataController.instance.set('selectedPlayer', player);
        _updateActionButtons(!isEquipped);
      },
      position: Vector2(size.x / 2, size.y - 100),
    );
    add(actionButton!);
  }

  void _addInventoryButton() {
    inventoryButton = SimpleButtonComponent.text(
      text: 'Change Equipment',
      size: Vector2(200, 50),
      color: Colors.blue,
      onPressed: () {
        final selectedPlayer =
            DataController.instance.get<GameCharacter>('selectedPlayer');
        if (selectedPlayer != null && equipment.slot.isNotEmpty) {
          SceneManager().pushScene('inventory', options: {
            'player': selectedPlayer,
            'slot': equipment.slot,
          });
        }
      },
      position: Vector2(size.x / 2, size.y - 40),
    );
    add(inventoryButton!);

    // Add a close button in the top right
    add(SimpleButtonComponent.text(
      text: 'X',
      size: Vector2(40, 40),
      color: Colors.grey.shade800,
      onPressed: () {
        removeFromParent();
      },
      position: Vector2(size.x - 50, 10),
    ));
  }

  void updateEquipment(EquipmentData newEquipment) {
    equipment = newEquipment;
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }
    final isEquipped = player.equipment[equipment.slot] == equipment.name;
    _updateActionButtons(isEquipped);
  }
}
