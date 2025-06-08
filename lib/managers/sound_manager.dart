import 'package:card_combat_app/models/card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _isInitialized = false;
  static const String _textSoundPath = 'assets/sounds/text_sound.mp3';

  // Map of card types to their corresponding sound files
  final Map<CardType, String> _cardTypeToSound = {
    CardType.attack: 'assets/sounds/swordattack.mp3',
    CardType.heal: 'assets/sounds/healing.mp3',
    CardType.statusEffect: 'assets/sounds/poison.mp3',
    CardType.cure: 'assets/sounds/healing.mp3', // Using healing sound for cure
    CardType.shield:
        'assets/sounds/card_play.mp3', // Using generic card play sound for shield
    CardType.shieldAttack: 'assets/sounds/heavystrike.mp3',
  };

  // Map of status effects to their corresponding sound files
  final Map<StatusEffect, String> _statusEffectToSound = {
    StatusEffect.poison: 'assets/sounds/poison.mp3',
    StatusEffect.burn: 'assets/sounds/damage.mp3',
    StatusEffect.freeze: 'assets/sounds/card_play.mp3',
    StatusEffect.none: 'assets/sounds/card_play.mp3',
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await FlameAudio.audioCache.loadAll([
        'assets/sounds/swordattack.mp3',
        'assets/sounds/healing.mp3',
        'assets/sounds/poison.mp3',
        'assets/sounds/card_play.mp3',
        'assets/sounds/heavystrike.mp3',
        'assets/sounds/damage.mp3',
      ]);
      await FlameAudio.audioCache.load(_textSoundPath);
      _isInitialized = true;
    } catch (e) {
      // Remove all print statements
    }
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

  void playTextSound() {
    if (!_isInitialized) return;

    try {
      FlameAudio.play(_textSoundPath, volume: 0.5);
    } catch (e) {
      // Remove all print statements
    }
  }
}
