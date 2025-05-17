import 'package:flutter/material.dart';
import 'package:card_combat_app/controllers/data_controller.dart';
import 'package:card_combat_app/scenes/scene_manager.dart';
import 'package:card_combat_app/models/game_card.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'base_scene.dart';
import 'package:flame/events.dart';

enum UpgradeType {
  card,
  energy,
  health,
  shield,
}

class CardUpgradeScene extends BaseScene with TapCallbacks {
  List<GameCard>? availableCards;
  GameCard? selectedCard;
  UpgradeType? selectedUpgradeType;
  final Map<UpgradeType, String> upgradeDescriptions = {
    UpgradeType.card: 'Upgrade a card\'s value',
    UpgradeType.energy: 'Increase max energy by 1',
    UpgradeType.health: 'Increase max health by 10',
    UpgradeType.shield: 'Increase starting shield by 5',
  };

  CardUpgradeScene() : super(sceneBackgroundColor: const Color(0xFF1A1A2E));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Get the player's deck from DataController
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player != null) {
      availableCards = List.from(player.deck);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final size = this.size;

    // Render title
    const titleText = 'Choose an Upgrade';
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: titleText,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(
      canvas,
      Offset((size.x - titlePainter.width) / 2, size.y * 0.05),
    );

    // Render upgrade options
    final upgradeTypes = UpgradeType.values;
    const optionWidth = 200.0;
    const optionHeight = 150.0;
    const spacing = 20.0;
    final startX =
        (size.x - (upgradeTypes.length * (optionWidth + spacing))) / 2;
    final startY = size.y * 0.15;

    for (var i = 0; i < upgradeTypes.length; i++) {
      final type = upgradeTypes[i];
      final isSelected = type == selectedUpgradeType;
      final optionRect = Rect.fromLTWH(
        startX + i * (optionWidth + spacing),
        startY,
        optionWidth,
        optionHeight,
      );

      // Draw option background
      final paint = Paint()
        ..color = isSelected ? Colors.blueAccent : Colors.grey.shade800;
      canvas.drawRRect(
        RRect.fromRectAndRadius(optionRect, const Radius.circular(12)),
        paint,
      );

      // Draw upgrade type name
      final namePainter = TextPainter(
        text: TextSpan(
          text: type.toString().split('.').last.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      namePainter.paint(
        canvas,
        Offset(
          optionRect.left + (optionWidth - namePainter.width) / 2,
          optionRect.top + 20,
        ),
      );

      // Draw upgrade description
      final descPainter = TextPainter(
        text: TextSpan(
          text: upgradeDescriptions[type] ?? '',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: optionWidth - 20);
      descPainter.paint(
        canvas,
        Offset(
          optionRect.left + 10,
          optionRect.top + 60,
        ),
      );
    }

    // Render cards if card upgrade is selected
    if (selectedUpgradeType == UpgradeType.card && availableCards != null) {
      const cardWidth = 200.0;
      const cardHeight = 300.0;
      const cardSpacing = 20.0;
      final cardStartX =
          (size.x - (availableCards!.length * (cardWidth + cardSpacing))) / 2;
      final cardStartY = size.y * 0.35;

      for (var i = 0; i < availableCards!.length; i++) {
        final card = availableCards![i];
        final isSelected = card == selectedCard;
        final cardRect = Rect.fromLTWH(
          cardStartX + i * (cardWidth + cardSpacing),
          cardStartY,
          cardWidth,
          cardHeight,
        );

        // Draw card background
        final paint = Paint()
          ..color = isSelected ? Colors.blueAccent : Colors.grey.shade800;
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(12)),
          paint,
        );

        // Draw card name
        final namePainter = TextPainter(
          text: TextSpan(
            text: card.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        namePainter.paint(
          canvas,
          Offset(
            cardRect.left + (cardWidth - namePainter.width) / 2,
            cardRect.top + 20,
          ),
        );

        // Draw card description
        final descPainter = TextPainter(
          text: TextSpan(
            text: card.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 3,
        )..layout(maxWidth: cardWidth - 20);
        descPainter.paint(
          canvas,
          Offset(
            cardRect.left + 10,
            cardRect.top + 60,
          ),
        );

        // Draw card stats
        final statsText = 'Cost: ${card.cost} | Value: ${card.value}';
        final statsPainter = TextPainter(
          text: TextSpan(
            text: statsText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        statsPainter.paint(
          canvas,
          Offset(
            cardRect.left + (cardWidth - statsPainter.width) / 2,
            cardRect.bottom - 40,
          ),
        );
      }
    }

    // Render upgrade button
    if (selectedUpgradeType != null &&
        (selectedUpgradeType != UpgradeType.card || selectedCard != null)) {
      const upgradeText = 'Apply Upgrade';
      final upgradePainter = TextPainter(
        text: const TextSpan(
          text: upgradeText,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final upgradeRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.9),
        width: upgradePainter.width + 40,
        height: 60,
      );
      final upgradePaint = Paint()..color = Colors.greenAccent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(upgradeRect, const Radius.circular(12)),
        upgradePaint,
      );
      upgradePainter.paint(
        canvas,
        Offset(
          upgradeRect.left + (upgradeRect.width - upgradePainter.width) / 2,
          upgradeRect.top + (upgradeRect.height - upgradePainter.height) / 2,
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final size = this.size;
    final pos = Offset(event.canvasPosition.x, event.canvasPosition.y);

    // Check upgrade type selection
    final upgradeTypes = UpgradeType.values;
    const optionWidth = 200.0;
    const optionHeight = 150.0;
    const spacing = 20.0;
    final startX =
        (size.x - (upgradeTypes.length * (optionWidth + spacing))) / 2;
    final startY = size.y * 0.15;

    for (var i = 0; i < upgradeTypes.length; i++) {
      final optionRect = Rect.fromLTWH(
        startX + i * (optionWidth + spacing),
        startY,
        optionWidth,
        optionHeight,
      );
      if (optionRect.contains(pos)) {
        selectedUpgradeType = upgradeTypes[i];
        selectedCard = null; // Reset card selection when changing upgrade type
        return;
      }
    }

    // Check card selection if card upgrade is selected
    if (selectedUpgradeType == UpgradeType.card && availableCards != null) {
      const cardWidth = 200.0;
      const cardHeight = 300.0;
      const cardSpacing = 20.0;
      final cardStartX =
          (size.x - (availableCards!.length * (cardWidth + cardSpacing))) / 2;
      final cardStartY = size.y * 0.35;

      for (var i = 0; i < availableCards!.length; i++) {
        final cardRect = Rect.fromLTWH(
          cardStartX + i * (cardWidth + cardSpacing),
          cardStartY,
          cardWidth,
          cardHeight,
        );
        if (cardRect.contains(pos)) {
          selectedCard = availableCards![i];
          return;
        }
      }
    }

    // Check upgrade button
    if (selectedUpgradeType != null &&
        (selectedUpgradeType != UpgradeType.card || selectedCard != null)) {
      const upgradeText = 'Apply Upgrade';
      final upgradePainter = TextPainter(
        text: const TextSpan(
          text: upgradeText,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final upgradeRect = Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.9),
        width: upgradePainter.width + 40,
        height: 60,
      );
      if (upgradeRect.contains(pos)) {
        _applyUpgrade();
        return;
      }
    }
  }

  void _applyUpgrade() {
    final player = DataController.instance.get<GameCharacter>('selectedPlayer');
    if (player == null) return;

    // Get current upgrade history
    List<Map<String, dynamic>> upgradeHistory = DataController.instance
            .get<List<Map<String, dynamic>>>('upgradeHistory') ??
        [];

    switch (selectedUpgradeType) {
      case UpgradeType.card:
        if (selectedCard != null) {
          // Create a new card with increased value
          final upgradedCard =
              selectedCard!.copyWith(value: selectedCard!.value + 2);
          // Replace the old card in the deck
          final cardIndex = player.deck.indexOf(selectedCard!);
          if (cardIndex != -1) {
            player.deck[cardIndex] = upgradedCard;
            // Add to upgrade history
            upgradeHistory.add({
              'type': 'Card Upgrade',
              'description':
                  '${selectedCard!.name} value increased to ${upgradedCard.value}',
            });
          }
        }
        break;
      case UpgradeType.energy:
        // Create a new player with increased max energy
        final upgradedPlayer = GameCharacter(
          name: player.name,
          maxHealth: player.maxHealth,
          attack: player.attack,
          defense: player.defense,
          emoji: player.emoji,
          color: player.color,
          imagePath: player.imagePath,
          soundPath: player.soundPath,
          description: player.description,
          deck: player.deck,
          maxEnergy: player.maxEnergy + 1,
          handSize: player.handSize,
        );
        DataController.instance.set('selectedPlayer', upgradedPlayer);
        // Add to upgrade history
        upgradeHistory.add({
          'type': 'Energy Upgrade',
          'description': 'Max energy increased to ${upgradedPlayer.maxEnergy}',
        });
        break;
      case UpgradeType.health:
        // Create a new player with increased max health
        final upgradedPlayer = GameCharacter(
          name: player.name,
          maxHealth: player.maxHealth + 10,
          attack: player.attack,
          defense: player.defense,
          emoji: player.emoji,
          color: player.color,
          imagePath: player.imagePath,
          soundPath: player.soundPath,
          description: player.description,
          deck: player.deck,
          maxEnergy: player.maxEnergy,
          handSize: player.handSize,
        );
        upgradedPlayer.currentHealth = upgradedPlayer.maxHealth;
        DataController.instance.set('selectedPlayer', upgradedPlayer);
        // Add to upgrade history
        upgradeHistory.add({
          'type': 'Health Upgrade',
          'description': 'Max health increased to ${upgradedPlayer.maxHealth}',
        });
        break;
      case UpgradeType.shield:
        // Create a new player with increased shield
        final upgradedPlayer = GameCharacter(
          name: player.name,
          maxHealth: player.maxHealth,
          attack: player.attack,
          defense: player.defense,
          emoji: player.emoji,
          color: player.color,
          imagePath: player.imagePath,
          soundPath: player.soundPath,
          description: player.description,
          deck: player.deck,
          maxEnergy: player.maxEnergy,
          handSize: player.handSize,
        );
        upgradedPlayer.shield = player.shield + 5;
        DataController.instance.set('selectedPlayer', upgradedPlayer);
        // Add to upgrade history
        upgradeHistory.add({
          'type': 'Shield Upgrade',
          'description':
              'Starting shield increased to ${upgradedPlayer.shield}',
        });
        break;
      default:
        break;
    }

    // Save updated upgrade history
    DataController.instance.set('upgradeHistory', upgradeHistory);

    // Return to player selection scene
    SceneManager().pushScene('player_selection');
  }
}
