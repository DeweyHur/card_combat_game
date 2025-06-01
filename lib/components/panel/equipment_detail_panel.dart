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

class EquipmentDetailPanel extends PositionComponent
    with TapCallbacks, VerticalStackMixin {
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
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    );
    registerVerticalStackComponent('background', background, size.y);

    // Add equipment details
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }

    final isEquipped = player.equipment[equipment.type] == equipment.name;

    // Add name
    final nameText = TextComponent(
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
    );
    registerVerticalStackComponent('name', nameText, 40);

    // Add type
    final typeText = TextComponent(
      text: 'Type: ${equipment.type}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 60),
    );
    registerVerticalStackComponent('type', typeText, 30);

    // Add rarity
    final rarityText = TextComponent(
      text: 'Rarity: ${equipment.rarity}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(20, 90),
    );
    registerVerticalStackComponent('rarity', rarityText, 30);

    // Add description if not empty
    if (equipment.description.isNotEmpty) {
      final descriptionText = TextComponent(
        text: 'Description: ${equipment.description}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        anchor: Anchor.topLeft,
        position: Vector2(20, 120),
      );
      registerVerticalStackComponent('description', descriptionText, 30);
    }

    // Add cards if any
    if (equipment.cards.isNotEmpty) {
      final cardsHeader = TextComponent(
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
      );
      registerVerticalStackComponent('cards_header', cardsHeader, 30);

      for (int i = 0; i < equipment.cards.length; i++) {
        final cardText = TextComponent(
          text: '• ${equipment.cards[i]}',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          anchor: Anchor.topLeft,
          position: Vector2(40, 180 + i * 25),
        );
        registerVerticalStackComponent('card_$i', cardText, 25);
      }
    }

    // Add action buttons
    _updateActionButtons(isEquipped);
    _addInventoryButton();
  }

  void _updateActionButtons(bool isEquipped) {
    // Remove existing button if any
    if (actionButton != null) {
      hideVerticalStackComponent('action_button');
    }

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
          player.unequip(equipment.type);
        } else {
          player.equip(equipment.type, equipment.name);
        }
        // Return to previous scene after equipping/unequipping
        SceneManager().popScene();
      },
    );
    registerVerticalStackComponent('action_button', actionButton!, 50);
  }

  void _addInventoryButton() {
    // Only show inventory button if we're not already in the inventory scene
    final inventoryPlayer =
        DataController.instance.get<GameCharacter>('inventory.player');
    final inventorySlot = DataController.instance.get<String>('inventory.slot');

    if (inventoryPlayer == null || inventorySlot == null) {
      inventoryButton = SimpleButtonComponent.text(
        text: 'Change Equipment',
        size: Vector2(200, 50),
        color: Colors.blue,
        onPressed: () {
          final selectedPlayer =
              DataController.instance.get<GameCharacter>('selectedPlayer');
          if (selectedPlayer != null && equipment.type.isNotEmpty) {
            SceneManager().pushScene('inventory', options: {
              'player': selectedPlayer,
              'slot': equipment.type,
            });
          }
        },
      );
      registerVerticalStackComponent('inventory_button', inventoryButton!, 50);
    }

    // Add a close button in the top right
    final closeButton = SimpleButtonComponent.text(
      text: 'X',
      size: Vector2(40, 40),
      color: Colors.grey.shade800,
      onPressed: () {
        hideVerticalStackComponent('background');
        hideVerticalStackComponent('name');
        hideVerticalStackComponent('type');
        hideVerticalStackComponent('rarity');
        if (equipment.description.isNotEmpty) {
          hideVerticalStackComponent('description');
        }
        if (equipment.cards.isNotEmpty) {
          hideVerticalStackComponent('cards_header');
          for (int i = 0; i < equipment.cards.length; i++) {
            hideVerticalStackComponent('card_$i');
          }
        }
        hideVerticalStackComponent('action_button');
        if (inventoryPlayer == null || inventorySlot == null) {
          hideVerticalStackComponent('inventory_button');
        }
        hideVerticalStackComponent('close_button');
      },
    );
    registerVerticalStackComponent('close_button', closeButton, 40);
  }

  void updateEquipment(EquipmentData newEquipment) {
    equipment = newEquipment;
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }
    final isEquipped = player.equipment[equipment.type] == equipment.name;
    _updateActionButtons(isEquipped);
  }
}
