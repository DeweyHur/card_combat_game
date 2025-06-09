import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/models/player.dart';
import 'package:card_combat_app/models/equipment.dart';
import 'package:card_combat_app/utils/game_logger.dart';
import 'package:card_combat_app/controllers/data_controller.dart';

class EquipmentSlotPanel extends PositionComponent {
  static const double _slotSize = 80.0;
  static const double _padding = 16.0;
  final Map<String, Vector2> _slotPositions = {
    'Head': Vector2(2 * _slotSize, 0),
    'Chest': Vector2(2 * _slotSize, _slotSize + _padding),
    'Belt': Vector2(2 * _slotSize, 2 * (_slotSize + _padding)),
    'Pants': Vector2(2 * _slotSize, 3 * (_slotSize + _padding)),
    'Shoes': Vector2(2 * _slotSize, 4 * (_slotSize + _padding)),
    'Weapon': Vector2(0, 2 * (_slotSize + _padding)),
    'Offhand': Vector2(4 * _slotSize, 2 * (_slotSize + _padding)),
    'Accessory 1': Vector2(0, 0),
    'Accessory 2': Vector2(4 * _slotSize, 0),
  };

  EquipmentSlotPanel()
      : super(size: Vector2(5 * _slotSize, 5 * (_slotSize + _padding)));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createSlots();
  }

  void _createSlots() {
    final setup =
        DataController.instance.get<PlayerSetup>('selectedPlayerSetup');
    if (setup == null) return;

    for (final slot in setup.template.equipmentSlots) {
      final position = _slotPositions[slot];
      if (position == null) continue;

      final equipment = setup.equipment[slot];
      final slotComponent = _EquipmentSlot(
        slot: slot,
        equipment: equipment,
        position: position,
        size: Vector2(_slotSize, _slotSize),
      );
      add(slotComponent);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw a simple person shape
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Head
    canvas.drawCircle(
      Offset(2 * _slotSize + _slotSize / 2, _slotSize / 2),
      _slotSize / 2,
      paint,
    );

    // Body
    canvas.drawLine(
      Offset(2 * _slotSize + _slotSize / 2, _slotSize),
      Offset(2 * _slotSize + _slotSize / 2, 4 * (_slotSize + _padding)),
      paint,
    );

    // Arms
    canvas.drawLine(
      Offset(2 * _slotSize + _slotSize / 2, 2 * (_slotSize + _padding)),
      Offset(_slotSize, 2 * (_slotSize + _padding)),
      paint,
    );
    canvas.drawLine(
      Offset(2 * _slotSize + _slotSize / 2, 2 * (_slotSize + _padding)),
      Offset(3 * _slotSize + _padding, 2 * (_slotSize + _padding)),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(2 * _slotSize + _slotSize / 2, 4 * (_slotSize + _padding)),
      Offset(_slotSize, 5 * (_slotSize + _padding)),
      paint,
    );
    canvas.drawLine(
      Offset(2 * _slotSize + _slotSize / 2, 4 * (_slotSize + _padding)),
      Offset(3 * _slotSize + _padding, 5 * (_slotSize + _padding)),
      paint,
    );
  }
}

class _EquipmentSlot extends PositionComponent {
  final String slot;
  final EquipmentTemplate? equipment;

  _EquipmentSlot({
    required this.slot,
    required this.equipment,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..color = equipment != null
          ? Colors.green.withOpacity(0.3)
          : Colors.blue.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );

    // Draw slot name
    final textPainter = TextPainter(
      text: TextSpan(
        text: slot,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x - 8);
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, 4),
    );

    // Draw equipment if any
    if (equipment != null) {
      final equipTextPainter = TextPainter(
        text: TextSpan(
          text: equipment!.name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      equipTextPainter.layout(maxWidth: size.x - 8);
      equipTextPainter.paint(
        canvas,
        Offset((size.x - equipTextPainter.width) / 2,
            size.y - equipTextPainter.height - 4),
      );
    }
  }
}
