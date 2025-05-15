import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';

class CapuccinoAssasino extends EnemyBase {
  CapuccinoAssasino() : super(
    name: 'Capuccino Assasino',
    maxHealth: 90,
    attack: 16,
    defense: 6,
    emoji: '☕️',
    color: 'brown',
    imagePath: 'capuccino_assasino.webp',
    soundPath: 'capuccino_assasino_italian_brainrot.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 70) {
      return const GameCard(
        name: 'Espresso Shot',
        description: 'A strong coffee attack',
        type: CardType.attack,
        value: 14,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Foam Heal',
        description: 'Heals with creamy foam',
        type: CardType.heal,
        value: 7,
      );
    } else {
      return const GameCard(
        name: 'Caffeine Confusion',
        description: 'Confuses the target with a caffeine rush',
        type: CardType.statusEffect,
        value: 5,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.3).round();
  }

  @override
  String get description => 'A caffeinated menace, quick and relentless. His espresso shots pack a punch!';
} 