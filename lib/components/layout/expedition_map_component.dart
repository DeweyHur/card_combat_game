import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/map/map_generator.dart';

class ExpeditionMapComponent extends PositionComponent {
  final MapStage mapStage;
  final int playerRow;
  final int playerCol;

  ExpeditionMapComponent({
    required this.mapStage,
    this.playerRow = 0,
    this.playerCol = 0,
    Vector2? size,
    Vector2? position,
  }) : super(size: size, position: position);

  static const double nodeRadius = 28;
  static const double verticalSpacing = 90;
  static const double horizontalSpacing = 90;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rows = mapStage.rows;
    final double mapWidth = size.x;
    final double mapHeight = size.y;
    final int numRows = rows.length;

    // Calculate node positions
    final nodePositions = <Offset>[];
    for (int row = 0; row < numRows; row++) {
      final cols = rows[row].length;
      for (int col = 0; col < cols; col++) {
        final double x = (mapWidth / (cols + 1)) * (col + 1);
        final double y = mapHeight - (row + 1) * (mapHeight / (numRows + 1));
        nodePositions.add(Offset(x, y));
      }
    }

    // Draw connections
    int nodeIndex = 0;
    for (int row = 0; row < numRows - 1; row++) {
      final cols = rows[row].length;
      for (int col = 0; col < cols; col++) {
        final node = rows[row][col];
        final from = nodePositions[nodeIndex];
        for (final nextCol in node.nextIndices) {
          final to = nodePositions[_nodeIndex(row + 1, nextCol)];
          final paint = Paint()
            ..color = Colors.white.withAlpha(120)
            ..strokeWidth = 3;
          canvas.drawLine(from, to, paint);
        }
        nodeIndex++;
      }
    }

    // Draw nodes
    nodeIndex = 0;
    for (int row = 0; row < numRows; row++) {
      final cols = rows[row].length;
      for (int col = 0; col < cols; col++) {
        final node = rows[row][col];
        final pos = nodePositions[nodeIndex];
        final isPlayer = (row == playerRow && col == playerCol);
        _drawNode(canvas, pos, node.type, isPlayer);
        nodeIndex++;
      }
    }
  }

  int _nodeIndex(int row, int col) {
    int idx = 0;
    for (int r = 0; r < row; r++) {
      idx += mapStage.rows[r].length;
    }
    return idx + col;
  }

  void _drawNode(Canvas canvas, Offset pos, MapNodeType type, bool isPlayer) {
    final Paint paint = Paint()
      ..color = isPlayer ? Colors.yellow : _nodeColor(type)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, nodeRadius, paint);
    // Draw border
    canvas.drawCircle(
        pos,
        nodeRadius,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    // Draw icon/text
    final text = _nodeIcon(type);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  String _nodeIcon(MapNodeType type) {
    switch (type) {
      case MapNodeType.battle:
        return '⚔️';
      case MapNodeType.quest:
        return '📜';
      case MapNodeType.event:
        return '❓';
      case MapNodeType.camp:
        return '🏕️';
      case MapNodeType.boss:
        return '👹';
      case MapNodeType.start:
        return '🚶';
    }
  }

  Color _nodeColor(MapNodeType type) {
    switch (type) {
      case MapNodeType.battle:
        return Colors.redAccent;
      case MapNodeType.quest:
        return Colors.blueAccent;
      case MapNodeType.event:
        return Colors.green;
      case MapNodeType.camp:
        return Colors.teal;
      case MapNodeType.boss:
        return Colors.deepPurple;
      case MapNodeType.start:
        return Colors.orange;
    }
  }
}
