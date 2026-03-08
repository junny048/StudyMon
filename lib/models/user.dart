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

  Map<String, Object> toMap() {
    return <String, Object>{
      'id': id,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'totalStudyTimeSeconds': totalStudyTime.inSeconds,
      'totalExp': totalExp,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      totalStudyTime: Duration(seconds: map['totalStudyTimeSeconds'] as int),
      totalExp: map['totalExp'] as int,
    );
  }
}
