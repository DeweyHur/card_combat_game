import 'package:flutter/material.dart';
import '../managers/sound_manager.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback onComplete;

  const AnimatedText({
    Key? key,
    required this.text,
    required this.style,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String _displayedText = '';
  int _currentIndex = 0;
  final SoundManager _soundManager = SoundManager();
  static const Duration _textSpeed = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(_textSpeed, () {
      if (mounted && _currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
          
          // Play sound for each character except spaces
          if (widget.text[_currentIndex - 1] != ' ') {
            _soundManager.playTextSound();
          }
        });
        _startAnimation();
      } else if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
} 