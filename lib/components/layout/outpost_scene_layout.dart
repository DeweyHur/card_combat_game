import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/panel/player_detail_panel.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_combat_app/components/mixins/vertical_stack_mixin.dart';

// Simple model for an outpost site
class OutpostSite {
  final String name;
  final String emoji;
  final String sceneName; // Scene to navigate to
  OutpostSite(
      {required this.name, required this.emoji, required this.sceneName});
}

class OutpostSceneLayout extends PositionComponent with VerticalStackMixin {
  late PlayerDetailPanel playerPanel;
  late OutpostGridComponent gridComponent;
  late final List<OutpostSite> sites;
  int selectedIndex = 0;

  OutpostSceneLayout();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = findGame()!.size;
    resetVerticalStack();

    // Log the selected player
    final player = DataController.instance.get('selectedPlayer');
    if (player != null) {
      GameLogger.info(LogCategory.game,
          'Outpost: Current player is: [32m[1m[4m[7m${player.name}[0m');
    } else {
      GameLogger.info(LogCategory.game, 'Outpost: No player selected');
    }

    // Player panel at the top
    playerPanel = PlayerDetailPanel()
      ..size = Vector2(size.x, size.y * 0.18)
      ..position = Vector2(0, 0)
      ..anchor = Anchor.topLeft;
    registerVerticalStackComponent('playerPanel', playerPanel, size.y * 0.18);

    // Define the sites in grid order
    sites = [
      OutpostSite(name: 'Back to Title', emoji: '🚪', sceneName: 'title'),
      OutpostSite(name: 'Armory', emoji: '🛡️', sceneName: 'equipment'),
      OutpostSite(name: 'Shop', emoji: '🛒', sceneName: 'shop'),
      OutpostSite(name: 'Expedition', emoji: '🗺️', sceneName: 'expedition'),
      OutpostSite(name: 'Tavern', emoji: '🍻', sceneName: 'tavern'),
    ];

    // Grid component below the player panel
    gridComponent = OutpostGridComponent(
      sites: sites,
      onSiteSelected: _onSiteSelected,
      playerIndex: selectedIndex,
    )
      ..size = Vector2(size.x, size.y - (size.y * 0.18))
      ..position = Vector2(0, size.y * 0.18)
      ..anchor = Anchor.topLeft;
    registerVerticalStackComponent(
        'gridComponent', gridComponent, size.y - (size.y * 0.18));
  }

  void _onSiteSelected(int index) async {
    selectedIndex = index;
    final site = sites[index];
    await Future.delayed(
        const Duration(milliseconds: 400)); // Simulate animation
    // Save game if going back to title
    if (site.sceneName == 'title') {
      final prefs = await SharedPreferences.getInstance();
      final player = DataController.instance.get('selectedPlayer');
      final coins = DataController.instance.get('coins');
      if (player != null) {
        prefs.setString('selectedPlayerName', player.name);
      }
      if (coins != null) {
        prefs.setInt('coins', coins);
      }
    }
    // Navigate to the selected scene
    SceneManager().pushScene(site.sceneName);
  }
}

class OutpostGridComponent extends PositionComponent {
  final List<OutpostSite> sites;
  final void Function(int) onSiteSelected;
  final int playerIndex;
  OutpostGridComponent({
    required this.sites,
    required this.onSiteSelected,
    required this.playerIndex,
  });

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
  _SiteButton({
    required this.site,
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
    this.showPlayer = false,
  }) {
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
