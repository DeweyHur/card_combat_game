import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerSelectionBox extends PositionComponent with TapCallbacks {
  final int index;
  bool isSelected = false;
  bool isHovered = false;

  late RectangleComponent background;
  late TextComponent nameText;
  late TextComponent emojiText;

  late final List<GameCharacter> players;

  PlayerSelectionBox({
    required Vector2 position,
    required Vector2 size,
    required this.index,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.topLeft,
  ) {
    players = DataController.instance.get<List<GameCharacter>>('players') ?? [];
  }

  bool get isSelectedPlayer {
    final selectedPlayer = DataController.instance.get<GameCharacter>('selectedPlayer');
    return selectedPlayer?.name == getPlayer().name;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set initial selection state from DataController
    isSelected = isSelectedPlayer;
    if (isSelected) {
      DataController.instance.set<GameCharacter>('selectedPlayer', getPlayer());
    }

    // Watch for changes to selectedPlayer
    DataController.instance.watch('selectedPlayer', (value) {
      final wasSelected = isSelected;
      isSelected = isSelectedPlayer;
      if (wasSelected != isSelected) {
        updateAppearance();
      }
    });

    // Create background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.3),
    );
    add(background);

    // Create border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    add(border);

    // Create text components
    final player = getPlayer();
    nameText = TextComponent(
      text: player.name,
      position: Vector2(size.x * 0.5, size.y * 0.3),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    add(nameText);

    emojiText = TextComponent(
      text: player.emoji,
      position: Vector2(size.x * 0.5, size.y * 0.7),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
    );
    add(emojiText);
  }

  GameCharacter getPlayer() {
    if (index < 0 || index >= players.length) {
      throw Exception('Invalid player index: $index');
    }
    return players[index];
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Set selectedPlayer in DataController
    DataController.instance.set<GameCharacter>('selectedPlayer', getPlayer());
  }

  void updateAppearance() {
    background.paint = Paint()
      ..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.black.withOpacity(0.3);
    }

  @override
  void onHoverEnter() {
    isHovered = true;
    if (!isSelected) {
      background.paint.color = Colors.grey.withOpacity(0.5);
    }
  }

  @override
  void onHoverExit() {
    isHovered = false;
    if (!isSelected) {
      background.paint.color = Colors.black.withOpacity(0.3);
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
           point.x <= position.x + size.x &&
           point.y >= position.y &&
           point.y <= position.y + size.y;
  }

  @override
  void render(Canvas canvas) {
    // Draw box background
    final paint = Paint()
      ..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );

    // Draw character name
    final nameText = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    nameText.render(
      canvas,
      getPlayer().name,
      Vector2(size.x * 0.5, size.y * 0.3),
      anchor: Anchor.center,
    );

    // Draw emoji
    final emojiText = TextPaint(
      style: const TextStyle(
        fontSize: 24,
      ),
    );
    emojiText.render(
      canvas,
      getPlayer().emoji,
      Vector2(size.x * 0.5, size.y * 0.7),
      anchor: Anchor.center,
    );
  }
} 