import 'package:flutter/material.dart';
import 'animated_text.dart';

class NintendoMessageBox extends StatefulWidget {
  final String character;
  final String message;
  final VoidCallback onNext;
  final bool showNextIndicator;

  const NintendoMessageBox({
    Key? key,
    required this.character,
    required this.message,
    required this.onNext,
    this.showNextIndicator = true,
  }) : super(key: key);

  @override
  State<NintendoMessageBox> createState() => _NintendoMessageBoxState();
}

class _NintendoMessageBoxState extends State<NintendoMessageBox> {
  bool _isTextComplete = false;

  void _handleTextComplete() {
    setState(() {
      _isTextComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.7 * 255).toInt()),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.character,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'PressStart2P',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedText(
              text: widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'PressStart2P',
              ),
              onComplete: _handleTextComplete,
            ),
          ),
          if (widget.showNextIndicator && _isTextComplete)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: widget.onNext,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
