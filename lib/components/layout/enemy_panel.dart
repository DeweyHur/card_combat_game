import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'base_panel.dart';

class EnemyPanel extends BasePanel {
  late TextComponent actionText;
  late RectangleComponent separatorLine;

  EnemyPanel(Vector2 gameSize) : super(
    gameSize: gameSize,
    characterEmoji: '👹',
    hpColor: Colors.red,
    isTop: true,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add separator line at the bottom
    separatorLine = RectangleComponent(
      size: Vector2(size.x, 2),
      position: Vector2(0, size.y - 40),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    add(separatorLine);

    // Add enemy action text at the very bottom
    actionText = TextComponent(
      text: 'Next Action: None',
      position: Vector2(size.x * 0.4, size.y * 0.7),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.centerLeft,
    );
    add(actionText);
  }

  void updateAction(String action) {
    actionText.text = 'Next Action: $action';
  }
} 