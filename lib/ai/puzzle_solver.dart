import 'dart:collection';
import 'package:collection/collection.dart';
import 'puzzle_state.dart';

class SolverResult {
  final List<List<int>> path;
  final int nodesExplored;
  final Duration executionTime;
  final String algorithmName;

  SolverResult({
    required this.path,
    required this.nodesExplored,
    required this.executionTime,
    required this.algorithmName,
  });
}

class PuzzleSolver {
  static SolverResult? solveBFS(List<int> initialBoard) {
    final startTime = DateTime.now();
    final initialState = PuzzleState(currentBoard: initialBoard);
    
    if (initialState.isGoal()) {
      return SolverResult(
        path: [initialState.board],
        nodesExplored: 1,
        executionTime: DateTime.now().difference(startTime),
        algorithmName: 'BFS',
      );
    }

    Queue<PuzzleState> queue = Queue();
    Set<String> visited = {};
    queue.add(initialState);
    visited.add(initialState.board.join(','));
    
    int nodesExplored = 0;

    while (queue.isNotEmpty) {
      PuzzleState current = queue.removeFirst();
      nodesExplored++;

      if (current.isGoal()) {
        return SolverResult(
          path: _reconstructPath(current),
          nodesExplored: nodesExplored,
          executionTime: DateTime.now().difference(startTime),
          algorithmName: 'BFS',
        );
      }

      for (var neighbor in current.generateNeighbors()) {
        String boardHash = neighbor.board.join(',');
        if (!visited.contains(boardHash)) {
          visited.add(boardHash);
          queue.add(neighbor);
        }
      }

      // Safeguard against infinite loops / solvable-check failures
      if (nodesExplored > 181440) { // Max states for 8-puzzle
        break;
      }
    }

    return null; // Unsolvable or limit reached
  }

  static SolverResult? solveAStar(List<int> initialBoard) {
    final startTime = DateTime.now();
    final initialState = PuzzleState(currentBoard: initialBoard);

    if (initialState.isGoal()) {
        return SolverResult(
          path: [initialState.board],
          nodesExplored: 1,
          executionTime: DateTime.now().difference(startTime),
          algorithmName: 'A*',
        );
    }

    int heuristic(PuzzleState state) => state.depth + state.getManhattanDistance();

    final priorityQueue = PriorityQueue<PuzzleState>((a, b) => heuristic(a).compareTo(heuristic(b)));
    priorityQueue.add(initialState);

    final visited = <String>{};
    visited.add(initialState.board.join(','));
    
    int nodesExplored = 0;

    while (priorityQueue.isNotEmpty) {
      PuzzleState current = priorityQueue.removeFirst();
      nodesExplored++;

      if (current.isGoal()) {
        return SolverResult(
          path: _reconstructPath(current),
          nodesExplored: nodesExplored,
          executionTime: DateTime.now().difference(startTime),
          algorithmName: 'A* (Manhattan)',
        );
      }

      for (var neighbor in current.generateNeighbors()) {
        String boardHash = neighbor.board.join(',');
        if (!visited.contains(boardHash)) {
          visited.add(boardHash);
          priorityQueue.add(neighbor);
        }
      }
      
      if (nodesExplored > 181440) {
        break;
      }
    }

    return null; // Unsolvable
  }

  static List<List<int>> _reconstructPath(PuzzleState state) {
    List<List<int>> path = [];
    PuzzleState? current = state;
    while (current != null) {
      path.add(current.board);
      current = current.previousState;
    }
    return path.reversed.toList();
  }

  static bool isSolvable(List<int> puzzle) {
    int inversions = 0;
    List<int> list = puzzle.where((e) => e != 0).toList();
    for (int i = 0; i < list.length - 1; i++) {
        for (int j = i + 1; j < list.length; j++) {
            if (list[i] > list[j]) inversions++;
        }
    }
    return inversions % 2 == 0;
  }
}
