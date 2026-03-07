import 'package:flutter/material.dart';
import 'package:studymon/models/monster.dart';
import 'package:studymon/models/study_session.dart';
import 'package:studymon/models/user.dart';
import 'package:studymon/screens/home_screen.dart';
import 'package:studymon/screens/monster_screen.dart';
import 'package:studymon/screens/plan_screen.dart';
import 'package:studymon/screens/study_timer_screen.dart';
import 'package:studymon/services/ai_planner_service.dart';
import 'package:studymon/services/exp_service.dart';
import 'package:studymon/services/study_service.dart';

void main() {
  runApp(const StudyMonApp());
}

class StudyMonApp extends StatefulWidget {
  const StudyMonApp({super.key});

  @override
  State<StudyMonApp> createState() => _StudyMonAppState();
}

class _StudyMonAppState extends State<StudyMonApp> {
  final ExpService _expService = ExpService();
  late final StudyService _studyService = StudyService(_expService);
  final AiPlannerService _aiPlannerService = AiPlannerService();

  late AppUser _user;
  late Monster _monster;
  final List<StudySession> _sessions = <StudySession>[];

  @override
  void initState() {
    super.initState();
    _user = AppUser(
      id: 'u-demo',
      email: 'demo@studymon.app',
      createdAt: DateTime.now(),
      totalStudyTime: Duration.zero,
      totalExp: 0,
    );
    _monster = Monster.initial(userId: _user.id);
  }

  Future<void> _startStudyFlow(BuildContext context) async {
    final StudySession? session = await Navigator.of(context)
        .push<StudySession>(
          MaterialPageRoute<StudySession>(
            builder: (_) =>
                StudyTimerScreen(userId: _user.id, studyService: _studyService),
          ),
        );

    if (!mounted || session == null) {
      return;
    }

    setState(() {
      _sessions.insert(0, session);
      _user = _user.copyWith(
        totalStudyTime: _user.totalStudyTime + session.duration,
        totalExp: _user.totalExp + session.expGained,
      );
      _monster = _monster.withAddedExp(session.expGained);
    });
  }

  void _openMonster(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MonsterScreen(monster: _monster, sessions: _sessions),
      ),
    );
  }

  void _openPlanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanScreen(aiPlannerService: _aiPlannerService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMon',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A7A5A),
          onPrimary: Colors.white,
          secondary: Color(0xFFE8B44B),
          onSecondary: Color(0xFF1C1C1C),
          surface: Color(0xFFF7F9F6),
          onSurface: Color(0xFF1B2A24),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1B2A24),
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withValues(alpha: 0.92),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          return HomeScreen(
            monster: _monster,
            todayStudyTime: _calculateTodayStudyTime(),
            onStartStudy: () => _startStudyFlow(context),
            onOpenMonster: () => _openMonster(context),
            onOpenPlanner: () => _openPlanner(context),
          );
        },
      ),
    );
  }

  Duration _calculateTodayStudyTime() {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return _sessions
        .where((session) => session.startTime.isAfter(startOfDay))
        .fold(Duration.zero, (sum, session) => sum + session.duration);
  }
}
