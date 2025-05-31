import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SimpleButtonComponent extends PositionComponent with TapCallbacks {
  final PositionComponent button;
  final TextComponent label;
  final VoidCallback? onPressed;

  SimpleButtonComponent({
    required this.button,
    required this.label,
    this.onPressed,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  factory SimpleButtonComponent.text({
    required String text,
    required Vector2 size,
    required Color color,
    VoidCallback? onPressed,
    Vector2? position,
  }) {
    final button = RectangleComponent(
      size: size,
      paint: Paint()..color = color,
      anchor: Anchor.center,
    );

    final label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );

    return SimpleButtonComponent(
      button: button,
      label: label,
      onPressed: onPressed,
      position: position,
      size: size,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    button.position = size / 2;
    add(button);
    add(label);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call();
  }
}
