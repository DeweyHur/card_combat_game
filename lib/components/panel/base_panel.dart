import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

abstract class BasePanel extends PositionComponent with VerticalStackMixin {
  late RectangleComponent background;
  late RectangleComponent border;

  BasePanel({super.size, super.position, super.anchor});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetVerticalStack();
    
    // Set size and position based on gameRef
    GameLogger.info(LogCategory.ui, '$runtimeType mounted at position ${position.x},${position.y} with size ${size.x}x${size.y}');

    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.3),
    );
    add(background);

    // Create border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    add(border);
  }

  @override
  void render(Canvas canvas) {
    // Render background first
    background.render(canvas);
    
    // Render child components
    super.render(canvas);
    
    // Render border last
    border.render(canvas);
  }

  // Abstract method that all panels must implement to update their UI
  void updateUI();
} 