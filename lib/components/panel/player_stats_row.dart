import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';

class PlayerStatsRow extends PositionComponent {
  final PlayerBase player;
  late TextComponent heartEmoji;
  late RectangleComponent healthBarBg;
  late RectangleComponent healthBarFg;
  late TextComponent hpText;
  late TextComponent attackEmoji;
  late TextComponent attackText;
  late TextComponent defenseEmoji;
  late TextComponent defenseText;
  late TextComponent energyEmoji;
  late TextComponent energyText;

  static const double barWidth = 100;
  static const double barHeight = 16;

  PlayerStatsRow({required this.player, Vector2? position, Vector2? size})
      : super(position: position ?? Vector2.zero(), size: size ?? Vector2(260, 32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Heart emoji
    heartEmoji = TextComponent(
      text: '❤️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20),
      ),
      position: Vector2(0, 0),
      anchor: Anchor.centerLeft,
    );
    add(heartEmoji);

    // Health bar background
    healthBarBg = RectangleComponent(
      size: Vector2(barWidth, barHeight),
      position: Vector2(28, 0),
      paint: Paint()..color = Colors.grey.shade800,
      anchor: Anchor.centerLeft,
    );
    add(healthBarBg);

    // Health bar foreground
    healthBarFg = RectangleComponent(
      size: Vector2(_healthBarFill(), barHeight),
      position: Vector2(28, 0),
      paint: Paint()..color = Colors.redAccent,
      anchor: Anchor.centerLeft,
    );
    add(healthBarFg);

    // HP text
    hpText = TextComponent(
      text: '${player.currentHealth}/${player.maxHealth}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 8, 0),
      anchor: Anchor.centerLeft,
    );
    add(hpText);

    // Attack emoji and value
    attackEmoji = TextComponent(
      text: '🗡️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 60, 0),
      anchor: Anchor.centerLeft,
    );
    add(attackEmoji);

    attackText = TextComponent(
      text: '${player.attack}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 80, 0),
      anchor: Anchor.centerLeft,
    );
    add(attackText);

    // Defense emoji and value
    defenseEmoji = TextComponent(
      text: '🛡️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 110, 0),
      anchor: Anchor.centerLeft,
    );
    add(defenseEmoji);

    defenseText = TextComponent(
      text: '${player.defense}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 130, 0),
      anchor: Anchor.centerLeft,
    );
    add(defenseText);

    // Energy bar and value
    energyText = TextComponent(
      text: _energyBarString(),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Colors.amber),
      ),
      position: Vector2(28 + barWidth + 160, 0),
      anchor: Anchor.centerLeft,
    );
    add(energyText);
  }

  double _healthBarFill() {
    if (player.maxHealth == 0) return 0;
    return barWidth * (player.currentHealth / player.maxHealth).clamp(0, 1);
  }

  void updateUI() {
    healthBarFg.size.x = _healthBarFill();
    hpText.text = '${player.currentHealth}/${player.maxHealth}';
    attackText.text = '${player.attack}';
    defenseText.text = '${player.defense}';
    energyText.text = _energyBarString();
  }

  String _energyBarString() {
    final filled = '⚡' * player.energy;
    final empty = '◇' * (player.maxEnergy - player.energy);
    return '$filled$empty ${player.energy}/${player.maxEnergy}';
  }
} 