import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';

class NameEmojiComponent extends PositionComponent {
  GameCharacter character;
  TextComponent? nameEmojiText;

  NameEmojiComponent({
    required this.character,
    Vector2? position,
    Vector2? size,
  }) : super(position: position ?? Vector2.zero(), size: size ?? Vector2(200, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiText = TextComponent(
      text: '${character.name} ${character.emoji}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(nameEmojiText!);
  }

  void updateCharacter(GameCharacter newCharacter) {
    character = newCharacter;
    if (nameEmojiText != null) {
      nameEmojiText!.text = '${character.name} ${character.emoji}';
    }
  }
} 