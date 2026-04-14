import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../ai/puzzle_solver.dart';
import '../providers/game_provider.dart';

class SolutionPathScreen extends ConsumerStatefulWidget {
  final SolverResult result;
  const SolutionPathScreen({Key? key, required this.result}) : super(key: key);

  @override
  ConsumerState<SolutionPathScreen> createState() => _SolutionPathScreenState();
}

class _SolutionPathScreenState extends ConsumerState<SolutionPathScreen> {
  int _currentStep = 0;
  Timer? _playTimer;
  bool _isPlaying = false;

  void _next() {
    if (_currentStep < widget.result.path.length - 1) {
      setState(() => _currentStep++);
    } else {
      _stopPlay();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopPlay();
    } else {
      setState(() => _isPlaying = true);
      _playTimer = Timer.periodic(const Duration(milliseconds: 600), (_) => _next());
    }
  }

  void _stopPlay() {
    _playTimer?.cancel();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.result.path[_currentStep];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Viewer'),
        leading: BackButton(
          onPressed: () {
            ref.read(gameProvider.notifier).markSolvedByAi();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('Step $_currentStep / ${widget.result.path.length - 1}', style: theme.textTheme.titleLarge),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final value = board[index];
                    return value == 0
                        ? const SizedBox.shrink()
                        : Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _currentStep > 0 ? _prev : null,
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 64,
                  color: theme.primaryColor,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  onPressed: _togglePlay,
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _currentStep < widget.result.path.length - 1 ? _next : null,
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
