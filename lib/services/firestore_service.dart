import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';

abstract class FirestoreService {
  static late FirestoreService instance;

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> incrementUserStats(String uid, {bool usedAi = false, int moves = -1});
  
  Future<void> saveGame(GameModel game);
  Future<List<GameModel>> getLeaderboard();
}

class MockFirestoreService implements FirestoreService {
  final Map<String, UserModel> _users = {};
  final List<GameModel> _games = [];

  @override
  Future<UserModel?> getUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users[uid];
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users[user.uid] = user;
  }

  @override
  Future<void> incrementUserStats(String uid, {bool usedAi = false, int moves = -1}) async {
    var user = _users[uid];
    if (user != null) {
      int best = user.bestMoves;
      if (moves != -1) {
        if (best == -1 || moves < best) best = moves;
      }
      
      _users[uid] = user.copyWith(
        gamesPlayed: user.gamesPlayed + 1,
        aiSolves: usedAi ? user.aiSolves + 1 : user.aiSolves,
        bestMoves: best,
      );
    }
  }

  @override
  Future<void> saveGame(GameModel game) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _games.add(game);
  }

  @override
  Future<List<GameModel>> getLeaderboard() async {
    await Future.delayed(const Duration(seconds: 1));
    var sorted = _games.where((g) => g.solved).toList()
      ..sort((a, b) => a.moves.compareTo(b.moves));
    return sorted.take(10).toList();
  }
}

class RealFirestoreService implements FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  @override
  Future<void> incrementUserStats(String uid, {bool usedAi = false, int moves = -1}) async {
    final docRef = _db.collection('users').doc(uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      int currentBest = snapshot.data()?['bestMoves'] ?? -1;
      int newBest = currentBest;
      if (moves != -1) {
        if (currentBest == -1 || moves < currentBest) newBest = moves;
      }

      int newAiSolves = (snapshot.data()?['aiSolves'] ?? 0) + (usedAi ? 1 : 0);
      int newGamesPlayed = (snapshot.data()?['gamesPlayed'] ?? 0) + 1;

      transaction.update(docRef, {
        'gamesPlayed': newGamesPlayed,
        'aiSolves': newAiSolves,
        'bestMoves': newBest,
      });
    });
  }

  @override
  Future<void> saveGame(GameModel game) async {
    await _db.collection('games').add(game.toMap());
  }

  @override
  Future<List<GameModel>> getLeaderboard() async {
    // Avoid composite index requirement by fetching top games and filtering locally
    final snapshot = await _db.collection('games')
        .orderBy('moves')
        .limit(20)
        .get();
        
    return snapshot.docs
        .map((d) => GameModel.fromMap(d.data(), d.id))
        .where((g) => g.solved)
        .take(10)
        .toList();
  }
}
