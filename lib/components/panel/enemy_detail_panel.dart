import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/base_enemy_panel.dart';
import 'package:card_combat_app/components/layout/multiline_text_component.dart';

class EnemyDetailPanel extends BaseEnemyPanel {
  MultilineTextComponent? descriptionComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Create multiline description text
    const textStyle = TextStyle(color: Colors.white, fontSize: 16);
    final description = _getEnemyDescription(enemy);
    descriptionComponent = MultilineTextComponent(
      text: description,
      style: textStyle,
      maxWidth: size.x,
    );
    registerVerticalStackComponent('descriptionComponent', descriptionComponent!, 20);
  }

  @override
  void onCombatEvent(event) {
    // No-op for detail panel
  }

  String _getEnemyDescription(GameCharacter enemy) {
    return enemy.description;
  }
} 