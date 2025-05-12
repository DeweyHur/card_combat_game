import 'package:flame/components.dart';
import 'package:card_combat_app/utils/game_logger.dart';

mixin VerticalStackMixin on PositionComponent {
  double _currentTopPos = 0.0;

  // Add a component to the vertical stack
  void addToVerticalStack(PositionComponent component, double height) {
    component.size = Vector2(size.x, height);
    component.position = Vector2(component.size.x / 2, _currentTopPos);
    component.anchor = Anchor.topCenter;
    add(component);
    
    // Update the current top position with fixed spacing
    _currentTopPos += component.size.y + 20;
    
    GameLogger.info(LogCategory.ui, 'Added component to vertical stack:');
    GameLogger.info(LogCategory.ui, '  - Component: ${component.runtimeType}');
    GameLogger.info(LogCategory.ui, '  - Position: ${component.position.x},${component.position.y}');
    GameLogger.info(LogCategory.ui, '  - Size: ${component.size.x},${component.size.y}');
    GameLogger.info(LogCategory.ui, '  - Current top position: $_currentTopPos');
  }

  // Reset the vertical stack position
  void resetVerticalStack() {
    _currentTopPos = 0.0;
    GameLogger.info(LogCategory.ui, 'Reset vertical stack position to 0');
  }
} 