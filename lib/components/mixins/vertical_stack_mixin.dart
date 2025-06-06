import 'package:flame/components.dart';

mixin VerticalStackMixin on PositionComponent {
  final Map<String, PositionComponent> _components = {};
  final Map<String, double> _componentHeights = {};
  PositionComponent? _backgroundComponent;
  double _currentHeight = 0;

  void resetVerticalStack() {
    _components.clear();
    _componentHeights.clear();
    _currentHeight = 0;
    _backgroundComponent = null;
  }

  void registerVerticalBackgroundComponent(
      String key, PositionComponent component) {
    if (_backgroundComponent != null) {
      _backgroundComponent!.removeFromParent();
    }
    _backgroundComponent = component;
    component.position = Vector2.zero();
    component.size = Vector2(size.x, 0);
    add(component);
    _updateBackgroundSize();
  }

  void registerVerticalStackComponent(
      String key, PositionComponent component, double height) {
    if (_components.containsKey(key)) {
      _components[key]!.removeFromParent();
    }
    _components[key] = component;
    _componentHeights[key] = height;
    component.position = Vector2(0, _currentHeight);
    component.size = Vector2(size.x, height);
    add(component);
    _currentHeight += height;
    _updateBackgroundSize();
  }

  void showVerticalStackComponent(String key) {
    if (_components.containsKey(key)) {
      final component = _components[key]!;
      if (!component.isMounted) {
        add(component);
        _updateBackgroundSize();
      }
    }
  }

  void hideVerticalStackComponent(String key) {
    if (_components.containsKey(key)) {
      final component = _components[key]!;
      if (component.isMounted) {
        component.removeFromParent();
        _updateBackgroundSize();
      }
    }
  }

  void _updateBackgroundSize() {
    if (_backgroundComponent != null) {
      double totalHeight = 0;
      for (final component in _components.values) {
        if (component.isMounted) {
          totalHeight += _componentHeights[component.key] ?? 0;
        }
      }
      _backgroundComponent!.size = Vector2(size.x, totalHeight);
    }
  }
}
