import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player/player_base.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/managers/combat_manager.dart';
import 'package:card_combat_app/components/panel/base_player_panel.dart';
import 'package:card_combat_app/components/effects/game_effects.dart';
import 'package:card_combat_app/components/mixins/area_filler_mixin.dart';
import 'package:card_combat_app/components/mixins/shake_mixin.dart';

class PlayerCombatPanel extends BasePlayerPanel with AreaFillerMixin, ShakeMixin implements CombatWatcher {
  final TextComponent playerDeckText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    anchor: Anchor.center,
  );
  final TextComponent playerHandText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    anchor: Anchor.center,
  );
  final TextComponent playerDiscardText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    anchor: Anchor.center,
  );
  final TextComponent playerStatusText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    anchor: Anchor.center,
  );
  TextComponent? actionText;
  RectangleComponent? separatorLine;
  late CombatManager combatManager;
  bool _isLoaded = false;

  PlayerCombatPanel({required super.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addToVerticalStack(playerDeckText, 24);
    addToVerticalStack(playerHandText, 24);
    addToVerticalStack(playerDiscardText, 24);
    addToVerticalStack(playerStatusText, 24);
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
    separatorLine = RectangleComponent(
      size: Vector2(280, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
    );
    addToVerticalStack(separatorLine!, 2);
    _isLoaded = true;
  }

  void initialize(PlayerBase player, CombatManager combatManager) {
    this.combatManager = combatManager;
    if (_isLoaded) {
      updateUI();
    }
  }

  @override
  void updateUI() {
    super.updateUI();
    if (!_isLoaded) return;
    final player = combatManager.player;
    playerDeckText.text = 'Deck: [36m${player.deck.length}[0m cards';
    playerHandText.text = 'Hand: [36m${player.hand.length}[0m cards';
    playerDiscardText.text = 'Discard: [36m${player.discardPile.length}[0m cards';
    playerStatusText.text = combatManager.isPlayerTurn ? 'Your Turn' : 'Opponent\'s Turn';
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

  @override
  void onCombatEvent(CombatEvent event) {
    if (event.target == player) {
      if (event.type == CombatEventType.damage) {
        final effect = GameEffects.createCardEffect(
          event.card?.type ?? CardType.attack,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          color: Colors.red,
          emoji: '💔',
          value: event.value,
        )..priority = 100;
        add(effect);
        shakeForType(event.card?.type ?? CardType.attack);
      } else if (event.type == CombatEventType.heal || event.type == CombatEventType.status) {
        final effect = GameEffects.createCardEffect(
          event.card?.type ?? CardType.heal,
          Vector2(size.x / 2 - 50, size.y / 2 - 50),
          Vector2(100, 100),
          onComplete: () {
            updateUI();
          },
          value: event.value,
        )..priority = 100;
        add(effect);
        shakeForType(event.card?.type ?? CardType.heal);
      } else if (event.type == CombatEventType.cure) {
        updateUI();
      }
    }
  }
} 