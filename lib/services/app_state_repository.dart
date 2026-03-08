import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymon/models/monster.dart';
import 'package:studymon/models/study_session.dart';
import 'package:studymon/models/user.dart';

class PersistedAppState {
  PersistedAppState({
    required this.user,
    required this.monster,
    required this.sessions,
  });

  final AppUser user;
  final Monster monster;
  final List<StudySession> sessions;
}

class AppStateRepository {
  static const String _stateKeyPrefix = 'app_state_v1_';

  String _stateKey(String userId) => '$_stateKeyPrefix$userId';

  Future<PersistedAppState?> load(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_stateKey(userId));

    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Map<String, dynamic> root = jsonDecode(raw) as Map<String, dynamic>;
    final AppUser user = AppUser.fromMap(root['user'] as Map<String, dynamic>);
    final Monster monster = Monster.fromMap(
      root['monster'] as Map<String, dynamic>,
    );
    final List<dynamic> sessionsRaw = root['sessions'] as List<dynamic>;

    final List<StudySession> sessions = sessionsRaw
        .map((item) => StudySession.fromMap(item as Map<String, dynamic>))
        .toList();

    return PersistedAppState(user: user, monster: monster, sessions: sessions);
  }

  Future<void> save({
    required String userId,
    required AppUser user,
    required Monster monster,
    required List<StudySession> sessions,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, Object> payload = <String, Object>{
      'user': user.toMap(),
      'monster': monster.toMap(),
      'sessions': sessions.map((session) => session.toMap()).toList(),
    };

    await prefs.setString(_stateKey(userId), jsonEncode(payload));
  }
}

class HybridAppStateRepository extends AppStateRepository {
  HybridAppStateRepository({
    required this.cloudClient,
    required this.localRepository,
  });

  final SupabaseClient cloudClient;
  final AppStateRepository localRepository;

  @override
  Future<PersistedAppState?> load(String userId) async {
    try {
      final PersistedAppState? cloud = await _loadFromCloud(userId);
      if (cloud != null) {
        await localRepository.save(
          userId: userId,
          user: cloud.user,
          monster: cloud.monster,
          sessions: cloud.sessions,
        );
        return cloud;
      }
    } catch (_) {}

    return localRepository.load(userId);
  }

  @override
  Future<void> save({
    required String userId,
    required AppUser user,
    required Monster monster,
    required List<StudySession> sessions,
  }) async {
    await localRepository.save(
      userId: userId,
      user: user,
      monster: monster,
      sessions: sessions,
    );

    try {
      await _saveToCloud(user: user, monster: monster, sessions: sessions);
    } catch (_) {}
  }

  Future<PersistedAppState?> _loadFromCloud(String userId) async {
    final List<Map<String, dynamic>> profileRows = await cloudClient
        .from('profiles')
        .select('id,email,created_at,total_study_time,total_exp')
        .eq('id', userId)
        .limit(1);

    if (profileRows.isEmpty) {
      return null;
    }

    final Map<String, dynamic> profile = profileRows.first;

    final List<Map<String, dynamic>> monsterRows = await cloudClient
        .from('monsters')
        .select('id,user_id,name,exp')
        .eq('user_id', userId)
        .limit(1);

    final List<Map<String, dynamic>> sessionRows = await cloudClient
        .from('study_sessions')
        .select('id,user_id,start_time,end_time,duration,exp_gained')
        .eq('user_id', userId)
        .order('start_time', ascending: false);

    final AppUser user = AppUser(
      id: profile['id'] as String,
      email: (profile['email'] as String?) ?? 'unknown@studymon.app',
      createdAt:
          DateTime.tryParse((profile['created_at'] as String?) ?? '') ??
          DateTime.now(),
      totalStudyTime: Duration(seconds: _asInt(profile['total_study_time'])),
      totalExp: _asInt(profile['total_exp']),
    );

    final Monster monster = monsterRows.isEmpty
        ? Monster.initial(userId: userId)
        : Monster.fromMap(monsterRows.first);

    final List<StudySession> sessions = sessionRows
        .map(
          (row) => StudySession(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            startTime: DateTime.parse(row['start_time'] as String),
            endTime: DateTime.parse(row['end_time'] as String),
            duration: Duration(seconds: _asInt(row['duration'])),
            expGained: _asInt(row['exp_gained']),
          ),
        )
        .toList();

    return PersistedAppState(user: user, monster: monster, sessions: sessions);
  }

  Future<void> _saveToCloud({
    required AppUser user,
    required Monster monster,
    required List<StudySession> sessions,
  }) async {
    await cloudClient.from('profiles').upsert(<String, Object>{
      'id': user.id,
      'email': user.email,
      'created_at': user.createdAt.toIso8601String(),
      'total_study_time': user.totalStudyTime.inSeconds,
      'total_exp': user.totalExp,
    }, onConflict: 'id');

    await cloudClient.from('monsters').upsert(<String, Object>{
      'id': monster.id,
      'user_id': monster.userId,
      'name': monster.name,
      'level': monster.level,
      'exp': monster.exp,
      'required_exp': monster.requiredExp,
    }, onConflict: 'id');

    if (sessions.isNotEmpty) {
      final List<Map<String, Object>> rows = sessions
          .map(
            (session) => <String, Object>{
              'id': session.id,
              'user_id': session.userId,
              'start_time': session.startTime.toIso8601String(),
              'end_time': session.endTime.toIso8601String(),
              'duration': session.duration.inSeconds,
              'exp_gained': session.expGained,
            },
          )
          .toList();

      await cloudClient.from('study_sessions').upsert(rows, onConflict: 'id');
    }
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
