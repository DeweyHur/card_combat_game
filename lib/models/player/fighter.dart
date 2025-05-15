import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_cards_data.dart';

class Fighter extends PlayerBase {
  Fighter() : super(
    name: 'Fighter',
    maxHealth: 100,
    attack: 15,
    defense: 8,
    emoji: '⚔️',
    color: 'green',
    deck: [
      slash,
      poison,
      heal,
      greaterHeal,
      cleanse,
    ],
    description: 'Medium HP, gets +1 energy per turn, attack cards deal +1 damage',
  );

  @override
  int get maxEnergy => 4;

  @override
  void onTurnStart() {
    super.onTurnStart();
    energy += 1; // Get +1 energy per turn
  }

  @override
  int calculateDamage(int baseDamage) {
    return baseDamage + 1; // Attack cards deal +1 damage
  }

  @override
  void playCard(GameCard card) {
    if (card.type == CardType.attack) {
      // Fighter's attack cards deal 1 additional damage
      card = GameCard(
        name: card.name,
        description: card.description,
        type: card.type,
        value: card.value + 1,
        statusEffectToApply: card.statusEffectToApply,
        statusDuration: card.statusDuration,
      );
    }
    super.playCard(card);
  }
} 