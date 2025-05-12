import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/panel/player_stats_row.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';

class PlayerPanel extends BasePanel with AreaFillerMixin {
  final TextComponent playerDeckText;
  final TextComponent playerHandText;
  final TextComponent playerDiscardText;
  final TextComponent playerStatusText;
  final PlayerBase player;
  late CombatManager combatManager;
  TextComponent? actionText;
  RectangleComponent? separatorLine;
  late PlayerStatsRow statsRow;
  late NameEmojiComponent nameEmojiComponent;
  bool _isLoaded = false;

  PlayerPanel({
    required this.player,
  }) : 
    playerDeckText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.center,
    ),
    playerHandText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.center,
    ),
    playerDiscardText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.center,
    ),
    playerStatusText = TextComponent(
      text: '',
      position: Vector2(0, 0), // Will be set in onLoad
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.center,
    );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add name + emoji at the top
    nameEmojiComponent = NameEmojiComponent(player: player);
    addToVerticalStack(nameEmojiComponent, 40);

    // Add stats row as the next row in the vertical stack
    statsRow = PlayerStatsRow(player: player);
    addToVerticalStack(statsRow, 40);

    // Add other UI components using vertical stack
    addToVerticalStack(playerDeckText, 24);
    addToVerticalStack(playerHandText, 24);
    addToVerticalStack(playerDiscardText, 24);
    addToVerticalStack(playerStatusText, 24);

    // Create and add extra text components using vertical stack
    actionText = TextComponent(
      text: 'Next Action: None',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    addToVerticalStack(actionText!, 20);

    // Add separator line
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    addToVerticalStack(separatorLine!, 2);

    _isLoaded = true;
    GameLogger.debug(LogCategory.ui, 'PlayerPanel loaded successfully');
  }

  void initialize(PlayerBase player, CombatManager combatManager) {
    this.combatManager = combatManager;
    if (_isLoaded) {
      updateUI();
    }
  }

  @override
  void updateUI() {
    if (!_isLoaded || combatManager == null) return;
    final player = combatManager.player;
    statsRow.updateUI();
    // Update other info
    playerDeckText.text = 'Deck: \u001b[36m${player.deck.length}\u001b[0m cards';
    playerHandText.text = 'Hand: \u001b[36m${player.hand.length}\u001b[0m cards';
    playerDiscardText.text = 'Discard: \u001b[36m${player.discardPile.length}\u001b[0m cards';
    playerStatusText.text = combatManager.isPlayerTurn ? 'Your Turn' : 'Opponent\'s Turn';
    if (actionText != null) {
      // actionText is handled below
    }
  }

  void updateAction(String action) {
    if (actionText != null) {
      actionText!.text = 'Next Action: $action';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawAreaFiller(
      canvas,
      player.color.withOpacity(0.3),
      borderColor: player.color,
      borderWidth: 2.0,
    );
  }
} 