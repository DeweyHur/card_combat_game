import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FadingTextComponent extends PositionComponent {
  final String text;
  late TextPaint _textComponent;
  final TextStyle _baseStyle;
  bool _isFinished = false;
  double _opacity = 1.0;
  static const double _fadeSpeed = 1.0;

  FadingTextComponent(
    this.text,
    Vector2 position, {
    TextStyle? style,
  }) : _baseStyle = style ?? const TextStyle(color: Colors.white),
       super(position: position) {
    _updateTextPaint();
  }

  void _updateTextPaint() {
    _textComponent = TextPaint(
      style: _baseStyle.copyWith(
        color: _baseStyle.color?.withOpacity(_opacity),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _opacity -= dt * _fadeSpeed;
    if (_opacity <= 0) {
      _opacity = 0;
      _isFinished = true;
    }
    _updateTextPaint();
  }

  @override
  void render(Canvas canvas) {
    _textComponent.render(
      canvas,
      text,
      position,
    );
  }

  bool get isFinished => _isFinished;
} 