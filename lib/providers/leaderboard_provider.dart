import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../services/firestore_service.dart';

final leaderboardProvider = FutureProvider<List<GameModel>>((ref) async {
  return await FirestoreService.instance.getLeaderboard();
});
