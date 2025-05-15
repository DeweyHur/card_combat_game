import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';

class BombardinoCrocodilo extends EnemyBase {
  BombardinoCrocodilo() : super(
    name: 'Bombardino Crocodilo',
    maxHealth: 95,
    attack: 16,
    defense: 5,
    emoji: '🐊',
    color: 'green',
    imagePath: 'bombardino_crocodilo.webp',
    soundPath: 'bombardino_crocodilo_italian_brainrot.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 70) {
      return const GameCard(
        name: 'Tail Whip',
        description: 'Whips with a powerful tail',
        type: CardType.attack,
        value: 14,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Swamp Heal',
        description: 'Heals in the swamp',
        type: CardType.heal,
        value: 7,
      );
    } else {
      return const GameCard(
        name: 'Croc Confusion',
        description: 'Confuses the target with a crocodile grin',
        type: CardType.statusEffect,
        value: 5,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.2).round();
  }

  @override
  String get description => 'A swampy crocodile with a tail that whips and a grin that confounds. Don\'t get too close!';
} 