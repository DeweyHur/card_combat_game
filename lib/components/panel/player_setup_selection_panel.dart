import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/managers/static_data_manager.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class PlayerSetupSelectionPanel extends PositionComponent {
  static const double _buttonHeight = 60.0;
  static const double _padding = 16.0;
  final List<PlayerTemplate> _templates = [];
  String? _selectedPlayerName;

  PlayerSetupSelectionPanel() : super(size: Vector2(300, 0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _templates.addAll(StaticDataManager.playerTemplates);
    size.y = _templates.length * (_buttonHeight + _padding) + _padding;
    _loadSelectedPlayer();
    _createButtons();
  }

  void _loadSelectedPlayer() {
    final setup =
        DataController.instance.get<PlayerSetup>('selectedPlayerSetup');
    if (setup != null) {
      _selectedPlayerName = setup.template.name;
    }
  }

  void _createButtons() {
    var yOffset = _padding;
    for (final template in _templates) {
      final button = _PlayerSetupButton(
        template: template,
        isSelected: template.name == _selectedPlayerName,
        position: Vector2(_padding, yOffset),
        size: Vector2(size.x - 2 * _padding, _buttonHeight),
        onTap: () => _handlePlayerSelected(template),
      );
      add(button);
      yOffset += _buttonHeight + _padding;
    }
  }

  void _handlePlayerSelected(PlayerTemplate template) {
    _selectedPlayerName = template.name;
    final setup = PlayerSetup(template);
    DataController.instance.set('selectedPlayerSetup', setup);
    GameLogger.info(
        LogCategory.game, 'Selected player setup: ${template.name}');
    _createButtons(); // Refresh buttons to update selection state
  }
}

class _PlayerSetupButton extends PositionComponent with TapCallbacks {
  final PlayerTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  _PlayerSetupButton({
    required this.template,
    required this.isSelected,
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..color = isSelected
          ? Colors.green.withOpacity(0.3)
          : Colors.blue.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${template.emoji} ${template.name}',
        style: TextStyle(
          fontSize: 24,
          color: isSelected ? Colors.green : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x - 16);
    textPainter.paint(
      canvas,
      Offset(
          (size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
