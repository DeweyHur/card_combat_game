import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';

class NameEmojiComponent extends PositionComponent {
  final PlayerBase player;
  late TextComponent nameEmojiText;

  NameEmojiComponent({
    required this.player,
    Vector2? position,
    Vector2? size,
  }) : super(position: position ?? Vector2.zero(), size: size ?? Vector2(200, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiText = TextComponent(
      text: '${player.name} ${player.emoji}',
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
    add(nameEmojiText);
  }

  void updatePlayer(PlayerBase newPlayer) {
    nameEmojiText.text = '${newPlayer.name} ${newPlayer.emoji}';
  }
} 