import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../services/firestore_service.dart';

final leaderboardProvider = StreamProvider<List<GameModel>>((ref) {
  return FirestoreService.instance.getLeaderboardStream();
});
