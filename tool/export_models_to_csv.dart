import 'dart:io';
import 'package:card_combat_app/models/player/knight.dart';
import 'package:card_combat_app/models/player/paladin.dart';
import 'package:card_combat_app/models/player/sorcerer.dart';
import 'package:card_combat_app/models/player/warlock.dart';
import 'package:card_combat_app/models/player/fighter.dart';
import 'package:card_combat_app/models/player/mage.dart';
import 'package:card_combat_app/models/enemies/trippi_troppi.dart';
import 'package:card_combat_app/models/enemies/trullimero_trullicina.dart';
import 'package:card_combat_app/models/enemies/tung_tung_tung_sahur.dart';
import 'package:card_combat_app/models/enemies/brr_brr_patapim.dart';
import 'package:card_combat_app/models/enemies/burbaloni_luliloli.dart';
import 'package:card_combat_app/models/enemies/capuccino_assasino.dart';
import 'package:card_combat_app/models/enemies/tralalero_tralala.dart';
import 'package:card_combat_app/models/enemies/ballerina_cappuccina.dart';
import 'package:card_combat_app/models/enemies/bobombini_goosini.dart';
import 'package:card_combat_app/models/enemies/bobrini_cocococini.dart';
import 'package:card_combat_app/models/enemies/bombardino_crocodilo.dart';
import 'package:card_combat_app/models/game_cards_data.dart';
import 'package:card_combat_app/models/game_card.dart';

void main() async {
  // Ensure output directory exists
  final dataDir = Directory('assets/data');
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }

  await exportPlayers();
  await exportEnemies();
  await exportCards();
  print('Export complete!');
}

Future<void> exportPlayers() async {
  final players = [
    Knight(),
    Paladin(),
    Sorcerer(),
    Warlock(),
    Fighter(),
    Mage(),
  ];
  final buffer = StringBuffer();
  buffer.writeln('name,maxHealth,attack,defense,emoji,color,deck,description,maxEnergy,special');
  for (final p in players) {
    final deckNames = p.deck.map((c) => c.name).join('|');
    buffer.writeln([
      p.name,
      p.maxHealth,
      p.attack,
      p.defense,
      p.emoji,
      p.color,
      deckNames,
      p.description.replaceAll(',', ';'),
      p.maxEnergy,
      _playerSpecial(p),
    ].join(','));
  }
  await File('assets/data/players.csv').writeAsString(buffer.toString());
}

String _playerSpecial(dynamic p) {
  // Add class-specific notes
  if (p is Knight) return 'Deals 20% more damage';
  if (p is Paladin) return 'Heals 2 HP/turn, healing +2';
  if (p is Sorcerer) return 'Draws extra card, status effects last longer';
  if (p is Warlock) return 'Takes 2 dmg/turn, +1 energy, attacks +2 dmg, +1 energy cost';
  if (p is Fighter) return '+1 energy/turn, attacks +1 dmg';
  if (p is Mage) return 'Deals 50% more damage';
  return '';
}

Future<void> exportEnemies() async {
  final enemies = [
    TrippiTroppi(),
    TrullimeroTrullicina(),
    TungTungTungSahur(),
    BrrBrrPatapim(),
    BurbaloniLuliloli(),
    CapuccinoAssasino(),
    TralaleroTralala(),
    BallerinaCappuccina(),
    BobombiniGoosini(),
    BobriniCocococini(),
    BombardinoCrocodilo(),
  ];
  final buffer = StringBuffer();
  buffer.writeln('name,maxHealth,attack,defense,emoji,color,imagePath,soundPath,description,special');
  for (final e in enemies) {
    buffer.writeln([
      e.name,
      e.maxHealth,
      e.attack,
      e.defense,
      e.emoji,
      e.color,
      e.imagePath,
      e.soundPath,
      e.description.replaceAll(',', ';'),
      '', // Add special notes if needed
    ].join(','));
  }
  await File('assets/data/enemies.csv').writeAsString(buffer.toString());
}

Future<void> exportCards() async {
  final buffer = StringBuffer();
  buffer.writeln('name,description,type,value,statusEffect,statusDuration,color');
  for (final c in gameCards) {
    buffer.writeln([
      c.name,
      c.description.replaceAll(',', ';'),
      c.type.toString().split('.').last,
      c.value,
      c.statusEffectToApply?.toString().split('.').last ?? '',
      c.statusDuration ?? '',
      c.color,
    ].join(','));
  }
  await File('assets/data/cards.csv').writeAsString(buffer.toString());
} 