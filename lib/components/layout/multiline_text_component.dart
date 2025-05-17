import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MultilineTextComponent extends PositionComponent {
  final TextStyle style;
  final double maxWidth;
  late final TextPaint _textPaint;
  List<String> _lines = [];
  double _height = 0;
  double _lineHeight = 0;
  String _text;

  String get text => _text;
  set text(String value) {
    _text = value;
    _lines = _splitTextToLines(_text, style, maxWidth);
    _height = _lines.length * _lineHeight;
    size = Vector2(maxWidth, _height);
  }

  MultilineTextComponent({
    required String text,
    required this.style,
    required this.maxWidth,
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
  })  : _text = text,
        super(
            position: position ?? Vector2.zero(),
            size: size ?? Vector2.zero(),
            anchor: anchor) {
    _textPaint = TextPaint(style: style);
    _lines = _splitTextToLines(_text, style, maxWidth);
    _lineHeight = _calculateLineHeight(style);
    _height = _lines.length * _lineHeight;
    this.size = Vector2(maxWidth, _height);
  }

  double _calculateLineHeight(TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: 'A', style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    tp.layout();
    return tp.height;
  }

  List<String> _splitTextToLines(
      String text, TextStyle style, double maxWidth) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      tp.text = TextSpan(text: testLine, style: style);
      tp.layout();
      if (tp.width > maxWidth && currentLine.isNotEmpty) {
        lines.add(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    double y = 0;
    for (final line in _lines) {
      _textPaint.render(canvas, line, Vector2(0, y));
      y += _lineHeight;
    }
  }
}
