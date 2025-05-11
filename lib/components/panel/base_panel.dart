import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/utils/game_logger.dart';

abstract class BasePanel extends PositionComponent {
  late RectangleComponent background;
  late RectangleComponent border;
  double _currentTopPos = 0.0;

  BasePanel() : super(
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set size and position based on gameRef
    GameLogger.info(LogCategory.ui, '${runtimeType} mounted at position ${position.x},${position.y} with size ${size.x}x${size.y}');

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

  // Add a component to the vertical stack
  void addToVerticalStack(PositionComponent component) {
    component.size.x = size.x;
    component.position = Vector2(component.size.x / 2, _currentTopPos);
    component.anchor = Anchor.center;
    add(component);
    
    // Update the current top position with fixed spacing
    _currentTopPos += component.size.y + 20;
    
    GameLogger.info(LogCategory.ui, 'Added component to vertical stack:');
    GameLogger.info(LogCategory.ui, '  - Component: ${component.runtimeType}');
    GameLogger.info(LogCategory.ui, '  - Position: ${component.position.x},${component.position.y}');
    GameLogger.info(LogCategory.ui, '  - Current top position: $_currentTopPos');
  }

  // Reset the vertical stack position
  void resetVerticalStack() {
    _currentTopPos = 0.0;
    GameLogger.info(LogCategory.ui, 'Reset vertical stack position to 0');
  }
} 