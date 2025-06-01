import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/equipment_loader.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class InventoryGridCell extends PositionComponent with TapCallbacks {
  final EquipmentData equipment;
  final bool isEquipped;
  final VoidCallback onTap;

  // Map equipment types to emojis
  static const Map<String, String> _typeEmojis = {
    'weapon': '⚔️',
    'armor': '🛡️',
    'head': '⛑️',
    'helmet': '⛑️',
    'hat': '🎩',
    'chest': '🦺',
    'robe': '👘',
    'pants': '👖',
    'leggings': '👖',
    'shoes': '👢',
    'boots': '👢',
    'gauntlets': '🧤',
    'gloves': '🧤',
    'ring': '💍',
    'amulet': '📿',
    'shield': '🛡️',
    'accessory': '✨',
    'charm': '✨',
    'manual': '📖',
  };

  InventoryGridCell({
    required this.equipment,
    required this.isEquipped,
    required this.onTap,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    final background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = isEquipped
            ? Colors.green.withAlpha(217)
            : Colors.black.withAlpha(217),
      anchor: Anchor.topLeft,
    );
    add(background);

    // Add emoji
    final emoji = _typeEmojis[equipment.type.toLowerCase()] ?? '❓';
    GameLogger.info(
      LogCategory.game,
      '[INV_CELL] Equipment: ${equipment.name}, Type: ${equipment.type}, Selected Emoji: $emoji',
    );
    GameLogger.info(
      LogCategory.game,
      '[INV_CELL] Available emoji mappings: ${_typeEmojis.entries.map((e) => '${e.key}: ${e.value}').join(", ")}',
    );

    final emojiText = TextComponent(
      text: emoji,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(emojiText);

    // Add name
    final nameText = TextComponent(
      text: equipment.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y - 4),
    );
    add(nameText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
