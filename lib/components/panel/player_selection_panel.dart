import 'package:flame/components.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/layout/player_selection_box.dart';
import 'package:card_combat_app/models/player.dart';

class PlayerSelectionPanel extends BasePanel with HasGameReference {
  final List<PlayerRun> playerRuns;
  final Function(PlayerRun) onPlayerSelected;

  PlayerSelectionPanel({
    required this.playerRuns,
    required this.onPlayerSelected,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    GameLogger.debug(LogCategory.ui, 'PlayerSelectionPanel loading...');

    // Create character selection boxes with relative sizing
    final boxWidth = size.x * 0.2;
    final boxHeight = size.y * 0.4;
    final spacing = size.x * 0.04;
    final startX =
        (size.x - 3 * (boxWidth + spacing)) * 0.5; // Center horizontally
    final startY = size.y * 0.04; // Start from top

    for (int i = 0; i < playerRuns.length; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final box = PlayerSelectionBox(
        position: Vector2(
          startX + (col * (boxWidth + spacing)),
          startY + (row * (boxHeight + spacing)),
        ),
        size: Vector2(boxWidth, boxHeight),
        playerRun: playerRuns[i],
        onSelected: onPlayerSelected,
      );
      add(box);
    }
  }

  @override
  void updateUI() {
    // Update any UI elements if needed
  }
}
