class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.totalStudyTime,
    required this.totalExp,
  });

  final String id;
  final String email;
  final DateTime createdAt;
  final Duration totalStudyTime;
  final int totalExp;

  AppUser copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    Duration? totalStudyTime,
    int? totalExp,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      totalExp: totalExp ?? this.totalExp,
    );
  }
}
