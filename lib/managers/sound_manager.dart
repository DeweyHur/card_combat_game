import 'package:flame_audio/flame_audio.dart';
import 'package:card_combat_app/models/game_card.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Map of card types to their corresponding sound files
  final Map<CardType, String> _cardTypeToSound = {
    CardType.attack: 'swordattack.mp3',
    CardType.heal: 'healing.mp3',
    CardType.statusEffect: 'poison.mp3',
    CardType.cure: 'healing.mp3', // Using healing sound for cure
    CardType.shield: 'card_play.mp3', // Using generic card play sound for shield
    CardType.shieldAttack: 'heavystrike.mp3',
  };

  // Map of status effects to their corresponding sound files
  final Map<StatusEffect, String> _statusEffectToSound = {
    StatusEffect.poison: 'poison.mp3',
    StatusEffect.burn: 'damage.mp3',
    StatusEffect.freeze: 'card_play.mp3',
    StatusEffect.none: 'card_play.mp3',
  };

  // Initialize audio files
  Future<void> initialize() async {
    // Preload all sound files
    await FlameAudio.audioCache.loadAll([
      'swordattack.mp3',
      'healing.mp3',
      'poison.mp3',
      'card_play.mp3',
      'heavystrike.mp3',
      'damage.mp3',
    ]);
  }

  // Play sound for a card type
  void playCardSound(CardType type) {
    final soundFile = _cardTypeToSound[type];
    if (soundFile != null) {
      FlameAudio.play(soundFile);
    }
  }

  // Play sound for a status effect
  void playStatusEffectSound(StatusEffect effect) {
    final soundFile = _statusEffectToSound[effect];
    if (soundFile != null) {
      FlameAudio.play(soundFile);
    }
  }

  // Play a specific sound file
  void playSound(String soundFile) {
    FlameAudio.play(soundFile);
  }
} 