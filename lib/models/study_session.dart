class StudySession {
  StudySession({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.expGained,
  });

  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int expGained;

  Map<String, Object> toMap() {
    return <String, Object>{
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'expGained': expGained,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      duration: Duration(seconds: map['durationSeconds'] as int),
      expGained: map['expGained'] as int,
    );
  }
}
