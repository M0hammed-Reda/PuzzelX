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
    Set<List<int>> visited = {};
    queue.add(initialState);
    visited.add(initialState.board);
    
    int nodesExplored = 0;

    final listEquality = const ListEquality();

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
        bool isVisited = visited.any((b) => listEquality.equals(b, neighbor.board));
        if (!isVisited) {
          visited.add(neighbor.board);
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

    final visited = <List<int>>{};
    visited.add(initialState.board);
    
    int nodesExplored = 0;
    final listEquality = const ListEquality();

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
        bool isVisited = visited.any((b) => listEquality.equals(b, neighbor.board));
        
        // In full A* we should check if we found a shorter path to a visited node.
        // For 8-puzzle with unit cost, depth is standard so basic visited check suffices for performance.
        if (!isVisited) {
          visited.add(neighbor.board);
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
