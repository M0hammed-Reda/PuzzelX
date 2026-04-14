import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../ai/puzzle_solver.dart';

class AiSolveResultScreen extends ConsumerStatefulWidget {
  const AiSolveResultScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiSolveResultScreen> createState() => _AiSolveResultScreenState();
}

class _AiSolveResultScreenState extends ConsumerState<AiSolveResultScreen> {
  bool _isSolving = false;
  SolverResult? _result;
  String? _selectedAlgorithm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      setState(() => _selectedAlgorithm = settings.defaultAlgorithm);
    });
  }

  void _solve() async {
    final board = ref.read(gameProvider).board;
    setState(() => _isSolving = true);

    // Yield to let the UI show the loading indicator
    await Future.delayed(const Duration(milliseconds: 100));

    SolverResult? result;
    if (_selectedAlgorithm == 'BFS') {
      result = PuzzleSolver.solveBFS(board);
    } else {
      result = PuzzleSolver.solveAStar(board);
    }

    setState(() {
      _isSolving = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Solver')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Algorithm', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'BFS', label: Text('Breadth-First Search')),
                ButtonSegment(value: 'A*', label: Text('A* Search')),
              ],
              selected: {_selectedAlgorithm ?? 'BFS'},
              onSelectionChanged: (val) => setState(() => _selectedAlgorithm = val.first),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSolving ? null : _solve,
              child: _isSolving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Solve Now', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 48),
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('Result Found!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 16),
                      _ResultRow('Algorithm', _result!.algorithmName),
                      _ResultRow('Steps', '${_result!.path.length - 1} moves'),
                      _ResultRow('Nodes Explored', '${_result!.nodesExplored}'),
                      _ResultRow('Computation Time', '${_result!.executionTime.inMilliseconds} ms'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                    // Navigate to Solution Path Viewer
                    context.push('/solution', extra: _result);
                },
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('View Solution Path'),
              )
            ] else if (!_isSolving && _result == null && _selectedAlgorithm != null)
              const Expanded(child: Center(child: Text('Press Solve Now to begin.'))),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
