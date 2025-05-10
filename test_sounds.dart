import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final audioPlayer = AudioPlayer();
  
  print('Testing sound files...');
  
  try {
    // Test card play sound
    print('\nTesting card_play.mp3...');
    await audioPlayer.setSource(AssetSource('sounds/card_play.mp3'));
    await audioPlayer.play(AssetSource('sounds/card_play.mp3'));
    print('card_play.mp3 is valid and playing');
    
    // Wait for sound to finish
    await Future.delayed(Duration(milliseconds: 300));
    
    // Test damage sound
    print('\nTesting damage.mp3...');
    await audioPlayer.setSource(AssetSource('sounds/damage.mp3'));
    await audioPlayer.play(AssetSource('sounds/damage.mp3'));
    print('damage.mp3 is valid and playing');
    
    // Wait for sound to finish
    await Future.delayed(Duration(milliseconds: 200));
    
  } catch (e) {
    print('Error testing sounds: $e');
  } finally {
    await audioPlayer.dispose();
  }
} 