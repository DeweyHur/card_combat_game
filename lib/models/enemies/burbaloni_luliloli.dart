import 'package:card_combat_app/models/enemies/enemy_base.dart';
import 'package:card_combat_app/models/game_card.dart';

class BurbaloniLuliloli extends EnemyBase {
  BurbaloniLuliloli() : super(
    name: 'Burbaloni Luliloli',
    maxHealth: 85,
    attack: 12,
    defense: 8,
    emoji: '🫧',
    color: 'lightBlueAccent',
    imagePath: 'burbaloni_luliloli.webp',
    soundPath: 'burbaloni_luliloli.mp3',
  );

  @override
  GameCard selectAction() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 65) {
      return const GameCard(
        name: 'Bubble Pop',
        description: 'Pops a bubble at the target',
        type: CardType.attack,
        value: 10,
      );
    } else if (random < 90) {
      return const GameCard(
        name: 'Soothing Foam',
        description: 'Heals with soothing foam',
        type: CardType.heal,
        value: 8,
      );
    } else {
      return const GameCard(
        name: 'Slippery Soap',
        description: 'Confuses the target with slippery soap',
        type: CardType.statusEffect,
        value: 3,
        statusEffectToApply: StatusEffect.poison,
        statusDuration: 2,
      );
    }
  }

  @override
  int calculateDamage(int baseDamage) {
    return (baseDamage * 1.1).round();
  }

  @override
  String get description => 'A bubbly spirit who attacks with popping bubbles and soothes with foamy waves.';
} 