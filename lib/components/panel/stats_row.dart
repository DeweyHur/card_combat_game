import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';

class StatsRow extends PositionComponent {
  GameCharacter character;
  late TextComponent heartEmoji;
  late RectangleComponent healthBarBg;
  late RectangleComponent healthBarFg;
  late TextComponent hpText;
  late TextComponent attackEmoji;
  late TextComponent attackText;
  late TextComponent defenseEmoji;
  late TextComponent defenseText;
  late TextComponent shieldEmoji;
  late TextComponent shieldText;
  late TextComponent energyEmoji;
  late TextComponent energyText;

  static const double barWidth = 100;
  static const double barHeight = 16;

  StatsRow({required this.character, Vector2? position, Vector2? size})
      : super(position: position ?? Vector2.zero(), size: size ?? Vector2(260, 32));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    heartEmoji = TextComponent(
      text: '❤️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(0, 0),
      anchor: Anchor.centerLeft,
    );
    add(heartEmoji);

    healthBarBg = RectangleComponent(
      size: Vector2(barWidth, barHeight),
      paint: Paint()..color = Colors.grey.withOpacity(0.3),
      position: Vector2(28, 0),
      anchor: Anchor.centerLeft,
    );
    add(healthBarBg);

    healthBarFg = RectangleComponent(
      size: Vector2(_healthBarFill(), barHeight),
      paint: Paint()..color = Colors.red,
      position: Vector2(28, 0),
      anchor: Anchor.centerLeft,
    );
    add(healthBarFg);

    hpText = TextComponent(
      text: '${character.maxHealth}/${character.maxHealth}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 10, 0),
      anchor: Anchor.centerLeft,
    );
    add(hpText);

    shieldEmoji = TextComponent(
      text: '🛡',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 60, 0),
      anchor: Anchor.centerLeft,
    );
    add(shieldEmoji);

    shieldText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 80, 0),
      anchor: Anchor.centerLeft,
    );
    add(shieldText);

    attackEmoji = TextComponent(
      text: '⚔️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 110, 0),
      anchor: Anchor.centerLeft,
    );
    add(attackEmoji);

    attackText = TextComponent(
      text: '${character.attack}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 130, 0),
      anchor: Anchor.centerLeft,
    );
    add(attackText);

    defenseEmoji = TextComponent(
      text: '🔰',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 160, 0),
      anchor: Anchor.centerLeft,
    );
    add(defenseEmoji);

    defenseText = TextComponent(
      text: '${character.defense}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 180, 0),
      anchor: Anchor.centerLeft,
    );
    add(defenseText);

    // Energy
    energyEmoji = TextComponent(
      text: '⚡',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18),
      ),
      position: Vector2(28 + barWidth + 210, 0),
      anchor: Anchor.centerLeft,
    );
    add(energyEmoji);

    energyText = TextComponent(
      text: '${character.currentEnergy}/${character.maxEnergy}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      position: Vector2(28 + barWidth + 230, 0),
      anchor: Anchor.centerLeft,
    );
    add(energyText);
  }

  double _healthBarFill() {
    if (character.maxHealth == 0) return 0;
    return barWidth * (character.currentHealth / character.maxHealth);
  }

  void updateUI() {
    healthBarFg.size.x = _healthBarFill();
    hpText.text = '${character.currentHealth}/${character.maxHealth}';
    shieldText.text = character.shield.toString();
    attackText.text = '${character.attack}';
    defenseText.text = '${character.defense}';
    energyText.text = '${character.currentEnergy}/${character.maxEnergy}';
  }

  void setCharacter(GameCharacter newCharacter) {
    character = newCharacter;
    if (isLoaded) {
      updateUI();
    }
  }
} 