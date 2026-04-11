import 'package:collection/collection.dart';

class PuzzleState {
  final List<int> currentBoard;
  final PuzzleState? previousState;
  final String move;
  final int cost;
  final int depth;

  PuzzleState({
    required this.currentBoard,
    this.previousState,
    this.move = '',
    this.cost = 0,
    this.depth = 0,
  });

  List<int> get board => currentBoard;

  bool isGoal() {
    const defaultGoal = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    return const ListEquality().equals(currentBoard, defaultGoal);
  }

  int _findBlankIndex() {
    return currentBoard.indexOf(0);
  }

  List<PuzzleState> generateNeighbors() {
    List<PuzzleState> neighbors = [];
    int blankIndex = _findBlankIndex();

    int row = blankIndex ~/ 3;
    int col = blankIndex % 3;

    // Directions: Up, Down, Left, Right
    final moves = {
      'Up': [-1, 0],
      'Down': [1, 0],
      'Left': [0, -1],
      'Right': [0, 1]
    };

    moves.forEach((moveName, direction) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];

      if (newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3) {
        int newBlankIndex = newRow * 3 + newCol;
        List<int> newBoard = List.from(currentBoard);
        
        // Swap
        newBoard[blankIndex] = newBoard[newBlankIndex];
        newBoard[newBlankIndex] = 0;

        neighbors.add(PuzzleState(
          currentBoard: newBoard,
          previousState: this,
          move: moveName,
          depth: depth + 1,
        ));
      }
    });

    return neighbors;
  }

  // Calculate Manhattan Distance for A*
  int getManhattanDistance() {
    int distance = 0;
    for (int i = 0; i < 9; i++) {
      int value = currentBoard[i];
      if (value != 0) {
        int targetRow = (value - 1) ~/ 3;
        int targetCol = (value - 1) % 3;
        int currentRow = i ~/ 3;
        int currentCol = i % 3;
        distance += (targetRow - currentRow).abs() + (targetCol - currentCol).abs();
      }
    }
    return distance;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PuzzleState && const ListEquality().equals(currentBoard, other.currentBoard);
  }

  @override
  int get hashCode => const ListEquality().hash(currentBoard);
}
