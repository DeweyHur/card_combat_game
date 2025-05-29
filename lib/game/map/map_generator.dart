import 'dart:math';

/// Types of map nodes.
enum MapNodeType { battle, quest, event, camp, boss, start }

/// Represents a node (space) on the map.
class MapNode {
  final int row;
  final int col;
  final MapNodeType type;
  final List<int> nextIndices; // Indices of connected nodes in the next row

  MapNode({
    required this.row,
    required this.col,
    required this.type,
    this.nextIndices = const [],
  });
}

/// Represents the whole map as a list of rows, each with nodes.
class MapStage {
  final List<List<MapNode>> rows;

  MapStage(this.rows);
}

class MapGenerator {
  final int minRows;
  final int maxRows;
  final int minCols;
  final int maxCols;
  final Random _rng;

  MapGenerator({
    this.minRows = 8,
    this.maxRows = 12,
    this.minCols = 2,
    this.maxCols = 5,
    int? seed,
  }) : _rng = Random(seed);

  MapStage generate() {
    final int numRows = minRows + _rng.nextInt(maxRows - minRows + 1);
    final List<List<MapNode>> rows = [];

    // Generate number of columns for each row
    final List<int> colsPerRow = List.generate(
      numRows,
      (i) => minCols + _rng.nextInt(maxCols - minCols + 1),
    );
    // Force top row to 1 (boss)
    colsPerRow[0] = 1;
    // Force bottom row to 1 (start)
    colsPerRow[numRows - 1] = 1;

    // Generate nodes row by row (from top to bottom)
    for (int row = 0; row < numRows; row++) {
      final int cols = colsPerRow[row];
      final List<MapNode> nodes = [];
      for (int col = 0; col < cols; col++) {
        MapNodeType type;
        if (row == 0) {
          type = MapNodeType.boss;
        } else if (row == numRows - 1) {
          type = MapNodeType.start;
        } else {
          type = _randomNodeType(row, numRows);
        }
        nodes.add(MapNode(row: row, col: col, type: type));
      }
      rows.add(nodes);
    }

    // Ensure one camp before boss (row 1)
    const campRow = 1;
    final campCol = _rng.nextInt(rows[campRow].length);
    rows[campRow][campCol] = MapNode(
      row: campRow,
      col: campCol,
      type: MapNodeType.camp,
    );

    // Connect nodes: each node connects to 1-3 nodes in the next row (except boss)
    for (int row = 0; row < numRows - 1; row++) {
      final List<MapNode> currentRow = rows[row];
      final List<MapNode> nextRow = rows[row + 1];
      for (int i = 0; i < currentRow.length; i++) {
        final int connections = 1 + _rng.nextInt(min(3, nextRow.length));
        final Set<int> nextIndices = {};
        while (nextIndices.length < connections) {
          nextIndices.add(_rng.nextInt(nextRow.length));
        }
        currentRow[i] = MapNode(
          row: currentRow[i].row,
          col: currentRow[i].col,
          type: currentRow[i].type,
          nextIndices: nextIndices.toList()..sort(),
        );
      }
    }

    return MapStage(rows);
  }

  MapNodeType _randomNodeType(int row, int numRows) {
    // Camp only on row 1 (handled above)
    // Start only on bottom, boss only on top
    // More battles, some quests/events
    final roll = _rng.nextDouble();
    if (roll < 0.55) return MapNodeType.battle;
    if (roll < 0.75) return MapNodeType.quest;
    return MapNodeType.event;
  }
}
