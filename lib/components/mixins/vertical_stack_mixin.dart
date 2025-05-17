import 'package:flame/components.dart';

class _VerticalStackEntry {
  final PositionComponent component;
  final double yPos;
  final double height;

  _VerticalStackEntry(this.component, this.yPos, this.height);
}

mixin VerticalStackMixin on PositionComponent {
  double _currentTopPos = 0.0;
  final Map<String, _VerticalStackEntry> _verticalStackEntries = {};

  // Register and add a component to the stack
  void registerVerticalStackComponent(String key, PositionComponent component, double height) {
    component.size = Vector2(size.x, height);
    final yPos = _currentTopPos;
    component.position = Vector2(component.size.x / 2, yPos);
    component.anchor = Anchor.topCenter;
    _verticalStackEntries[key] = _VerticalStackEntry(component, yPos, height);
    add(component);
    _currentTopPos += height;
  }

  // Show a registered component
  void showVerticalStackComponent(String key) {
    final entry = _verticalStackEntries[key];
    if (entry != null && !children.contains(entry.component)) {
      entry.component.position = Vector2(entry.component.size.x / 2, entry.yPos);
      add(entry.component);
    }
  }

  // Hide a registered component
  void hideVerticalStackComponent(String key) {
    final entry = _verticalStackEntries[key];
    if (entry != null && children.contains(entry.component)) {
      entry.component.removeFromParent();
    }
  }

  // Reset the stack
  void resetVerticalStack() {
    _currentTopPos = 0.0;
    _verticalStackEntries.clear();
  }
} 