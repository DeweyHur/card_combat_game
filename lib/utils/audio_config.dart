import 'package:flame_audio/flame_audio.dart';

class AudioConfig {
  static Future<void> initialize() async {
    // Configure Flame Audio to look in the correct directory
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.prefix = ''; // Remove prefix since we're using full paths
  }
} 