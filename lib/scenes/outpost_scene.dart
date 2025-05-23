import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/scenes/base_scene.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';

// Simple model for an outpost site
class OutpostSite {
  final String name;
  final String emoji;
  final String sceneName; // Scene to navigate to
  OutpostSite(
      {required this.name, required this.emoji, required this.sceneName});
}

class OutpostScene extends BaseScene {
  OutpostScene({Map<String, dynamic>? options})
      : super(sceneBackgroundColor: Colors.brown.shade200, options: options);

  late final List<OutpostSite> sites;
  late Vector2 playerPosition;
  int selectedIndex = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Define the sites in grid order
    sites = [
      OutpostSite(name: 'Entrance', emoji: '🚪', sceneName: 'title'),
      OutpostSite(name: 'Armory', emoji: '🛡️', sceneName: 'equipment'),
      OutpostSite(
          name: 'Shop',
          emoji: '🛒',
          sceneName: 'shop'), // Placeholder, implement shop scene
      OutpostSite(name: 'Expedition', emoji: '🗺️', sceneName: 'combat'),
      OutpostSite(
          name: 'Tavern',
          emoji: '🍻',
          sceneName: 'tavern'), // Example extra site
    ];
    // Initial player position at Entrance (index 0)
    playerPosition = _sitePosition(0);
    add(OutpostGridComponent(
        sites: sites,
        onSiteSelected: _onSiteSelected,
        playerIndex: selectedIndex));
  }

  void _onSiteSelected(int index) async {
    // Animate player avatar to the selected site (handled in component)
    selectedIndex = index;
    final site = sites[index];
    await Future.delayed(
        const Duration(milliseconds: 400)); // Simulate animation
    // Navigate to the selected scene
    SceneManager().pushScene(site.sceneName);
  }

  // Helper to get grid position for a site index (for animation, if needed)
  Vector2 _sitePosition(int index) {
    // 2x2 grid for now
    const double cellSize = 200;
    return Vector2((index % 2) * cellSize, (index ~/ 2) * cellSize);
  }
}

class OutpostGridComponent extends PositionComponent {
  final List<OutpostSite> sites;
  final void Function(int) onSiteSelected;
  final int playerIndex;
  OutpostGridComponent(
      {required this.sites,
      required this.onSiteSelected,
      required this.playerIndex});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add grid buttons and player avatar
    const double cellSize = 200;
    for (int i = 0; i < sites.length; i++) {
      final site = sites[i];
      add(_SiteButton(
        site: site,
        position: Vector2((i % 2) * cellSize, (i ~/ 2) * cellSize),
        size: Vector2(cellSize, cellSize),
        onTap: () => onSiteSelected(i),
        showPlayer: i == playerIndex,
      ));
    }
  }
}

class _SiteButton extends PositionComponent with TapCallbacks {
  final OutpostSite site;
  final VoidCallback onTap;
  final bool showPlayer;
  _SiteButton(
      {required this.site,
      required Vector2 position,
      required Vector2 size,
      required this.onTap,
      this.showPlayer = false}) {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 0.8);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)), paint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${site.emoji}\n${site.name}',
        style: const TextStyle(fontSize: 36, color: Colors.black, height: 1.2),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x);
    textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2));
    if (showPlayer) {
      final playerPainter = TextPainter(
        text: const TextSpan(text: '🧑', style: TextStyle(fontSize: 40)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      playerPainter.layout();
      playerPainter.paint(
          canvas, Offset((size.x - playerPainter.width) / 2, 8));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onTap();
  }
}
