class GameModel {
  final String id;
  final String uid;
  final String playerName;
  final List<int> puzzleState;
  final int moves;
  final int timeSeconds;
  final bool solved;
  final String algorithmUsed; 

  GameModel({
    required this.id,
    required this.uid,
    required this.playerName,
    required this.puzzleState,
    required this.moves,
    required this.timeSeconds,
    required this.solved,
    required this.algorithmUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'playerName': playerName,
      'puzzleState': puzzleState,
      'moves': moves,
      'timeSeconds': timeSeconds,
      'solved': solved,
      'algorithmUsed': algorithmUsed,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map, String docId) {
    return GameModel(
      id: docId,
      uid: map['uid'] ?? '',
      playerName: map['playerName'] ?? 'Unknown',
      puzzleState: List<int>.from(map['puzzleState'] ?? []),
      moves: map['moves']?.toInt() ?? 0,
      timeSeconds: map['timeSeconds']?.toInt() ?? 0,
      solved: map['solved'] ?? false,
      algorithmUsed: map['algorithmUsed'] ?? 'None',
    );
  }
}
