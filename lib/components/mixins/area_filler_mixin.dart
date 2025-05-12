import 'package:flutter/material.dart';
import 'package:flame/components.dart';

mixin AreaFillerMixin on PositionComponent {
  void drawAreaFiller(
    Canvas canvas,
    Color fillColor, {
    Color? borderColor,
    double borderWidth = 2.0,
  }) {
    // Draw background
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(position.x, position.y, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor ?? fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRect(
      Rect.fromLTWH(position.x, position.y, size.x, size.y),
      borderPaint,
    );
  }
} 