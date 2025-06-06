import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/enemy.dart';

class StatsRow extends PositionComponent {
  GameCharacter character;
  final TextComponent healthText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 20,
      ),
    ),
  );

  final TextComponent attackText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 20,
      ),
    ),
  );

  final TextComponent defenseText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const material.TextStyle(
        color: material.Colors.white,
        fontSize: 20,
      ),
    ),
  );

  StatsRow({required this.character}) {
    add(healthText);
    add(attackText);
    add(defenseText);
    updateUI();
  }

  void setCharacter(GameCharacter newCharacter) {
    character = newCharacter;
    updateUI();
  }

  void updateUI() {
    healthText.text = 'HP: ${character.currentHealth}/${character.maxHealth}';

    // Get attack and defense based on character type
    int attack = 0;
    int defense = 0;

    if (character is PlayerRun) {
      attack = (character as PlayerRun).attack;
      defense = (character as PlayerRun).defense;
    } else if (character is EnemyRun) {
      attack = (character as EnemyRun).template.attack;
      defense = (character as EnemyRun).template.defense;
    }

    attackText.text = 'ATK: $attack';
    defenseText.text = 'DEF: $defense';
  }
}
