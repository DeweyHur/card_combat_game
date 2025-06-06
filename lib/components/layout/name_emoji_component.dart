import 'package:card_combat_app/models/name_emoji_interface.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;

class NameEmojiComponent extends PositionComponent {
  NameEmojiInterface character;
  final TextComponent nameText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 24,
      ),
    ),
  );

  final TextComponent emojiText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 32,
      ),
    ),
  );

  NameEmojiComponent({required this.character}) {
    add(nameText);
    add(emojiText);
    updateCharacter(character);
  }

  void updateCharacter(NameEmojiInterface newCharacter) {
    character = newCharacter;
    nameText.text = character.name;
    emojiText.text = character.emoji;
  }
}
