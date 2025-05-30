import 'package:card_combat_app/models/card_loader.dart';
import 'package:card_combat_app/models/game_card.dart';

/// Cards are now loaded from assets/data/cards.csv at runtime.
Future<List<GameCard>> loadAllGameCards() async {
  final result = await loadCardsByOwnerFromCsv('assets/data/cards.csv');
  return result.cardsByName.values.toList();
}

class GameCardsData {
  final Map<String, List<GameCard>> ownerCards;
  final Map<String, GameCard> cardsByName;

  GameCardsData({
    required this.ownerCards,
    required this.cardsByName,
  });

  List<GameCard> getAllCards() {
    return cardsByName.values.toList();
  }

  List<GameCard> getCardsByOwner(String owner) {
    return ownerCards[owner] ?? [];
  }

  GameCard? getCardByName(String name) {
    return cardsByName[name];
  }
}
