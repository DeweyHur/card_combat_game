import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class FadingTextComponent extends PositionComponent with HasPaint {
  late TextComponent _textComponent;

  FadingTextComponent(String text, Vector2 position, {TextStyle? style}) {
    this.position = position;
    final textRenderer = TextPaint(
      style: style ?? const TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    );
    _textComponent = TextComponent(
      text: text,
      textRenderer: textRenderer,
      anchor: Anchor.center,
    );
    add(_textComponent);
    paint = BasicPalette.white.paint();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Color effectColor = paint.color;
    _textComponent.textRenderer = TextPaint(
      style: (_textComponent.textRenderer as TextPaint)
          .style
          .copyWith(color: (_textComponent.textRenderer as TextPaint).style.color?.withOpacity(effectColor.opacity)),
    );
  }
} 