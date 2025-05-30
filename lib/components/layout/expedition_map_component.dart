import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:card_combat_app/game/map/map_generator.dart';

class ExpeditionMapComponent extends PositionComponent with TapCallbacks {
  final MapStage mapStage;
  int playerRow;
  int playerCol;
  List<(int, int)> selectableNodes;
  final void Function(int row, int col)? onNodeTap;

  ExpeditionMapComponent({
    required this.mapStage,
    this.playerRow = 0,
    this.playerCol = 0,
    this.selectableNodes = const [],
    this.onNodeTap,
    Vector2? size,
    Vector2? position,
  }) : super(size: size, position: position);

  static const double nodeRadius = 28;
  static const double verticalSpacing = 90;
  static const double horizontalSpacing = 90;

  late List<Offset> _nodePositions;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rows = mapStage.rows;
    final double mapWidth = size.x;
    final double mapHeight = size.y;
    final int numRows = rows.length;

    // Calculate node positions
    _nodePositions = <Offset>[];
    for (int row = 0; row < numRows; row++) {
      final cols = rows[row].length;
      for (int col = 0; col < cols; col++) {
        final double x = (mapWidth / (cols + 1)) * (col + 1);
        final double y = mapHeight - (row + 1) * (mapHeight / (numRows + 1));
        _nodePositions.add(Offset(x, y));
      }
    }

    // Draw connections
    int nodeIndex = 0;
    for (int row = 0; row < numRows - 1; row++) {
      final cols = rows[row].length;
      for (int col = 0; col < cols; col++) {
        final node = rows[row][col];
        final from = _nodePositions[nodeIndex];
        for (final nextCol in node.nextIndices) {
          final to = _nodePositions[_nodeIndex(row + 1, nextCol)];
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
        final pos = _nodePositions[nodeIndex];
        final isPlayer = (row == playerRow && col == playerCol);
        final isSelectable = selectableNodes.contains((row, col));
        _drawNode(canvas, pos, node.type, isPlayer, isSelectable);
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

  void _drawNode(Canvas canvas, Offset pos, MapNodeType type, bool isPlayer,
      bool isSelectable) {
    final Paint paint = Paint()
      ..color = isPlayer
          ? Colors.yellow
          : isSelectable
              ? Colors.lightBlueAccent
              : _nodeColor(type)
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

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (onNodeTap == null) return;
    // Find which node (if any) was tapped
    for (int i = 0; i < _nodePositions.length; i++) {
      final pos = _nodePositions[i];
      if ((event.canvasPosition.toOffset() - pos).distance <= nodeRadius) {
        // Convert flat index to (row, col)
        int idx = i;
        int row = 0;
        while (idx >= mapStage.rows[row].length) {
          idx -= mapStage.rows[row].length;
          row++;
        }
        int col = idx;
        if (selectableNodes.contains((row, col))) {
          onNodeTap!(row, col);
        }
        break;
      }
    }
  }
}
