import 'card_loader.dart';
import 'game_card.dart';

/// Cards are now loaded from assets/data/cards.csv at runtime.
Future<List<GameCard>> loadAllGameCards() async {
  final ownerMap = await loadCardsByOwnerFromCsv('assets/data/cards.csv');
  return ownerMap.values.expand((cards) => cards).toList();
} 