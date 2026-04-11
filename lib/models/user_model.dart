class UserModel {
  final String uid;
  final String name;
  final String email;
  final int gamesPlayed;
  final int bestMoves;
  final int aiSolves;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.gamesPlayed = 0,
    this.bestMoves = -1,
    this.aiSolves = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gamesPlayed': gamesPlayed,
      'bestMoves': bestMoves,
      'aiSolves': aiSolves,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gamesPlayed: map['gamesPlayed']?.toInt() ?? 0,
      bestMoves: map['bestMoves']?.toInt() ?? -1,
      aiSolves: map['aiSolves']?.toInt() ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? gamesPlayed,
    int? bestMoves,
    int? aiSolves,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestMoves: bestMoves ?? this.bestMoves,
      aiSolves: aiSolves ?? this.aiSolves,
    );
  }
}
