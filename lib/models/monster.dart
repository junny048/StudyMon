class Monster {
  Monster({
    required this.id,
    required this.userId,
    required this.name,
    required this.level,
    required this.exp,
    required this.requiredExp,
  });

  final String id;
  final String userId;
  final String name;
  final int level;
  final int exp;
  final int requiredExp;

  static const List<int> _levelThresholds = [0, 100, 300, 600, 1000, 1500];

  static Monster initial({required String userId, String name = 'Brainy'}) {
    return fromExp(id: 'monster-$userId', userId: userId, name: name, exp: 0);
  }

  static Monster fromExp({
    required String id,
    required String userId,
    required String name,
    required int exp,
  }) {
    final int level = _levelForExp(exp);
    final int requiredExp = _requiredExpForLevel(level);

    return Monster(
      id: id,
      userId: userId,
      name: name,
      level: level,
      exp: exp,
      requiredExp: requiredExp,
    );
  }

  Monster withAddedExp(int gainedExp) {
    return Monster.fromExp(
      id: id,
      userId: userId,
      name: name,
      exp: exp + gainedExp,
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'id': id,
      'userId': userId,
      'name': name,
      'exp': exp,
    };
  }

  factory Monster.fromMap(Map<String, dynamic> map) {
    return Monster.fromExp(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      exp: map['exp'] as int,
    );
  }

  static int _levelForExp(int exp) {
    for (int i = _levelThresholds.length - 1; i >= 0; i--) {
      if (exp >= _levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  static int _requiredExpForLevel(int level) {
    if (level >= _levelThresholds.length) {
      return _levelThresholds.last + 500;
    }
    return _levelThresholds[level];
  }

  double get progressToNextLevel {
    if (level >= _levelThresholds.length) {
      return 1;
    }

    final int currentMinExp = _levelThresholds[level - 1];
    final int nextLevelExp = _levelThresholds[level];
    final int range = nextLevelExp - currentMinExp;

    if (range <= 0) {
      return 1;
    }

    return ((exp - currentMinExp) / range).clamp(0, 1);
  }
}
