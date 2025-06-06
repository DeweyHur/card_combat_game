import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/components/simple_button_component.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

class EquipmentDetailPanel extends PositionComponent
    with TapCallbacks, VerticalStackMixin {
  late EquipmentTemplate equipment;
  SimpleButtonComponent? actionButton;
  SimpleButtonComponent? inventoryButton;

  EquipmentDetailPanel();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.game,
        '[EQUIP_PANEL] Panel loading for equipment: ${equipment.name}');

    // Add equipment details
    final player = DataController.instance.get<PlayerRun>('selectedPlayer');
    if (player == null) {
      GameLogger.error(LogCategory.game, '[EQUIP_PANEL] No player found');
      return;
    }
    GameLogger.debug(
        LogCategory.game, '[EQUIP_PANEL] Selected player: ${player.name}');

    final isEquipped = player.equipment[equipment.type] == equipment;
    GameLogger.debug(LogCategory.game,
        '[EQUIP_PANEL] Equipment type: ${equipment.type}, isEquipped: $isEquipped');

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
    );
    registerVerticalStackComponent('rarity', rarityText, 30);

    // Add description if not empty
    if (equipment.description.isNotEmpty) {
      final descriptionText = TextComponent(
        text: 'Description: ${equipment.description}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      registerVerticalStackComponent('description', descriptionText, 60);
    }

    // Add cards if any
    if (equipment.cards.isNotEmpty) {
      final cardsText = TextComponent(
        text: 'Cards:',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      registerVerticalStackComponent('cards_header', cardsText, 30);

      for (int i = 0; i < equipment.cards.length; i++) {
        final cardText = TextComponent(
          text: '• ${equipment.cards[i]}',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
        registerVerticalStackComponent('card_$i', cardText, 25);
      }
    }

    // Add action button
    actionButton = SimpleButtonComponent.text(
      text: isEquipped ? 'Unequip' : 'Equip',
      size: Vector2(200, 50),
      color: isEquipped ? Colors.red : Colors.green,
      onPressed: () {
        if (isEquipped) {
          player.unequip(equipment.type);
        } else {
          player.equip(equipment.type, equipment);
        }
        updateUI();
      },
    );
    registerVerticalStackComponent('action', actionButton!, 60);

    // Add inventory button
    inventoryButton = SimpleButtonComponent.text(
      text: 'Change Equipment',
      size: Vector2(200, 50),
      color: Colors.blue,
      onPressed: () {
        final selectedPlayer =
            DataController.instance.get<PlayerRun>('selectedPlayer');
        if (selectedPlayer != null && equipment.type.isNotEmpty) {
          DataController.instance
              .setSceneData('inventory', 'player', selectedPlayer);
          DataController.instance
              .setSceneData('inventory', 'slot', equipment.type);
          SceneManager().pushScene('inventory', options: {
            'player': selectedPlayer,
            'slot': equipment.type,
          });
        }
      },
    );
    registerVerticalStackComponent('inventory', inventoryButton!, 60);
  }

  void updateUI() {
    final player = DataController.instance.get<PlayerRun>('selectedPlayer');
    if (player == null) return;

    // Update description
    if (equipment.description.isNotEmpty) {
      final descriptionText = TextComponent(
        text: 'Description: ${equipment.description}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      registerVerticalStackComponent('description', descriptionText, 60);
    }

    // Update cards
    if (equipment.cards.isNotEmpty) {
      final cardsText = TextComponent(
        text: 'Cards:',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      registerVerticalStackComponent('cards_header', cardsText, 30);

      for (int i = 0; i < equipment.cards.length; i++) {
        final cardText = TextComponent(
          text: '• ${equipment.cards[i]}',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
        registerVerticalStackComponent('card_$i', cardText, 25);
      }
    }

    // Update action button
    final isEquipped = player.equipment[equipment.type] == equipment;
    if (actionButton != null) {
      remove(actionButton!);
      actionButton = SimpleButtonComponent.text(
        text: isEquipped ? 'Unequip' : 'Equip',
        size: Vector2(200, 50),
        color: isEquipped ? Colors.red : Colors.green,
        onPressed: () {
          if (isEquipped) {
            player.unequip(equipment.type);
          } else {
            player.equip(equipment.type, equipment);
          }
          updateUI();
        },
      );
      registerVerticalStackComponent('action', actionButton!, 60);
    }
  }

  void updateEquipment(EquipmentTemplate newEquipment) {
    equipment = newEquipment;
    updateUI();
  }
}
