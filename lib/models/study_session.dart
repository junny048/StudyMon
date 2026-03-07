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
}
