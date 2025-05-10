import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/components/layout/enemy_panel.dart';
import 'package:card_combat_app/components/layout/player_panel.dart';
import 'package:card_combat_app/components/layout/cards_panel.dart';
import 'package:card_combat_app/utils/game_logger.dart';

class GameUI extends PositionComponent {
  late EnemyPanel enemyPanel;
  late PlayerPanel playerPanel;
  late CardsPanel cardsPanel;

  GameUI(Vector2 gameSize) {
    size = gameSize;
  }

  @override
  Future<void> onLoad() async {
    // Create enemy panel
    enemyPanel = EnemyPanel(size);
    add(enemyPanel);

    // Create player panel
    playerPanel = PlayerPanel(size);
    add(playerPanel);

    // Calculate remaining space for cards panel
    final panelHeight = size.y * 0.3; // Height of enemy/player panels
    final cardsPanelPosition = Vector2(0, panelHeight);
    final cardsPanelSize = Vector2(size.x, size.y - (panelHeight * 2));

    // Create cards panel with calculated space
    cardsPanel = CardsPanel(
      position: cardsPanelPosition,
      size: cardsPanelSize,
    );
    add(cardsPanel);
    GameLogger.info(LogCategory.ui, 'CardsPanel added to GameUI');
  }

  void updateEnemyHp(int currentHp, int maxHp) {
    enemyPanel.updateHp(currentHp, maxHp);
  }

  void updatePlayerHp(int currentHp, int maxHp) {
    playerPanel.updateHp(currentHp, maxHp);
  }

  void updateEnemyAction(String action) {
    enemyPanel.updateAction(action);
  }

  void updatePlayerStatus(String status) {
    playerPanel.updateStatus(status);
  }

  void updateGameInfo(String info) {
    cardsPanel.updateGameInfo(info);
  }

  void updateTurn(int turn) {
    cardsPanel.updateTurn(turn);
  }

  void updateTurnText(String text) {
    cardsPanel.updateGameInfo(text);
  }

  void updateCardAreaText(String text) {
    cardsPanel.updateGameInfo(text);
  }

  void showGameMessage(String message) {
    cardsPanel.updateGameInfo(message);
  }

  void updateTurnInfo(String turnText, int turnCount) {
    cardsPanel.updateGameInfo(turnText);
    cardsPanel.updateTurn(turnCount);
  }

  Vector2 get cardAreaPosition => cardsPanel.position;
  Vector2 get cardAreaSize => cardsPanel.size;
  Vector2 get enemyAreaPosition => enemyPanel.position;
  Vector2 get enemyAreaSize => enemyPanel.size;
  Vector2 get playerAreaPosition => playerPanel.position;
  Vector2 get playerAreaSize => playerPanel.size;
} 