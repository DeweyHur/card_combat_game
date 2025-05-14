import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/character.dart';
import 'package:card_combat_app/utils/game_logger.dart';

abstract class EnemyBase extends Character {
  final String imagePath;
  final String soundPath;

  EnemyBase({
    required super.name,
    required super.maxHealth,
    required super.attack,
    required super.defense,
    required super.emoji,
    required super.color,
    required this.imagePath,
    required this.soundPath,
  });

  void takeAction(PlayerBase target) {
    final action = selectAction();
    GameLogger.info(LogCategory.combat, '$name uses ${action.name}');

    switch (action.type) {
      case CardType.attack:
        final damage = calculateDamage(action.value);
        target.takeDamage(damage);
        GameLogger.info(LogCategory.combat, '$name deals $damage damage to ${target.name}');
        break;
      case CardType.statusEffect:
        final effect = action.statusEffectToApply;
        final duration = action.statusDuration;
        if (effect != null && duration != null) {
          target.addStatusEffect(effect, duration);
          GameLogger.info(LogCategory.combat, '$name applies $effect to ${target.name} for $duration turns');
        }
        break;
      case CardType.heal:
        final healAmount = action.value;
        heal(healAmount);
        GameLogger.info(LogCategory.combat, '$name heals for $healAmount');
        break;
      case CardType.cure:
        removeStatusEffect();
        GameLogger.info(LogCategory.combat, '$name removes status effects');
        break;
    }
  }

  int calculateDamage(int baseDamage) {
    return baseDamage;
  }

  GameCard selectAction();

  String get description;

  @override
  GameCard getNextAction() {
    return selectAction();
  }
} 