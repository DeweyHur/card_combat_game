import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioPlayer = AudioPlayer();

  debugPrint('Testing sound files...');

  try {
    // Test card play sound
    debugPrint('\nTesting card_play.mp3...');
    await audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
    await audioPlayer.play(AssetSource('sounds/card_play.mp3'));
    debugPrint('card_play.mp3 is valid and playing');

    // Wait for sound to finish
    await Future.delayed(const Duration(milliseconds: 300));

    // Test damage sound
    debugPrint('\nTesting damage.mp3...');
    await audioPlayer.setSource(AssetSource('sounds/damage.mp3'));
    await audioPlayer.play(AssetSource('sounds/damage.mp3'));
    debugPrint('damage.mp3 is valid and playing');

    // Wait for sound to finish
    await Future.delayed(const Duration(milliseconds: 200));
  } catch (e) {
    debugPrint('Error testing sounds: $e');
  } finally {
    await audioPlayer.dispose();
  }
}
