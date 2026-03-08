import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymon/models/monster.dart';
import 'package:studymon/models/study_session.dart';
import 'package:studymon/models/user.dart';
import 'package:studymon/screens/auth_screen.dart';
import 'package:studymon/screens/home_screen.dart';
import 'package:studymon/screens/monster_screen.dart';
import 'package:studymon/screens/plan_screen.dart';
import 'package:studymon/screens/study_timer_screen.dart';
import 'package:studymon/services/ai_planner_service.dart';
import 'package:studymon/services/app_state_repository.dart';
import 'package:studymon/services/auth_service.dart';
import 'package:studymon/services/exp_service.dart';
import 'package:studymon/services/study_service.dart';
import 'package:studymon/services/supabase_bootstrap.dart';

Future<void> main() async {
  await SupabaseBootstrap.initialize();
  runApp(
    StudyMonApp(
      authService: SupabaseAuthService(
        isConfigured: SupabaseBootstrap.isConfigured,
      ),
      enableCloudSync: SupabaseBootstrap.isConfigured,
    ),
  );
}

class StudyMonApp extends StatefulWidget {
  const StudyMonApp({
    super.key,
    required this.authService,
    this.appStateRepository,
    this.enableCloudSync = false,
  });

  final AuthService authService;
  final AppStateRepository? appStateRepository;
  final bool enableCloudSync;

  @override
  State<StudyMonApp> createState() => _StudyMonAppState();
}

class _StudyMonAppState extends State<StudyMonApp> {
  final ExpService _expService = ExpService();
  late final StudyService _studyService = StudyService(_expService);
  final AiPlannerService _aiPlannerService = AiPlannerService();
  late final AppStateRepository _appStateRepository =
      widget.appStateRepository ??
      (widget.enableCloudSync
          ? HybridAppStateRepository(
              cloudClient: Supabase.instance.client,
              localRepository: AppStateRepository(),
            )
          : AppStateRepository());

  final List<StudySession> _sessions = <StudySession>[];

  late AuthStatus _authStatus;
  AppUser? _user;
  Monster? _monster;
  bool _isLoadingState = false;
  StreamSubscription<AuthStatus>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authStatus = widget.authService.currentStatus;

    _authSubscription = widget.authService.authStatusChanges.listen(
      _handleAuthStatus,
    );

    if (_authStatus.isSignedIn) {
      _restoreStateForAuthUser(_authStatus);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthStatus(AuthStatus status) async {
    if (!mounted) {
      return;
    }

    if (!status.isSignedIn) {
      setState(() {
        _authStatus = status;
        _user = null;
        _monster = null;
        _sessions.clear();
        _isLoadingState = false;
      });
      return;
    }

    await _restoreStateForAuthUser(status);
  }

  Future<void> _restoreStateForAuthUser(AuthStatus status) async {
    final String userId = status.userId!;

    setState(() {
      _authStatus = status;
      _isLoadingState = true;
    });

    final AppUser defaultUser = AppUser(
      id: userId,
      email: status.email ?? 'unknown@studymon.app',
      createdAt: DateTime.now(),
      totalStudyTime: Duration.zero,
      totalExp: 0,
    );

    final Monster defaultMonster = Monster.initial(userId: userId);

    final PersistedAppState? persisted = await _appStateRepository.load(userId);

    if (!mounted) {
      return;
    }

    setState(() {
      _user = persisted?.user.copyWith(email: status.email) ?? defaultUser;
      _monster = persisted?.monster ?? defaultMonster;
      _sessions
        ..clear()
        ..addAll(persisted?.sessions ?? <StudySession>[]);
      _isLoadingState = false;
    });
  }

  Future<void> _saveState() async {
    final AppUser? user = _user;
    final Monster? monster = _monster;
    if (user == null || monster == null) {
      return;
    }

    await _appStateRepository.save(
      userId: user.id,
      user: user,
      monster: monster,
      sessions: _sessions,
    );
  }

  Future<void> _startStudyFlow(BuildContext context) async {
    final AppUser? user = _user;
    final Monster? monster = _monster;
    if (user == null || monster == null) {
      return;
    }

    final StudySession? session = await Navigator.of(context)
        .push<StudySession>(
          MaterialPageRoute<StudySession>(
            builder: (_) =>
                StudyTimerScreen(userId: user.id, studyService: _studyService),
          ),
        );

    if (!mounted || session == null) {
      return;
    }

    setState(() {
      _sessions.insert(0, session);
      _user = user.copyWith(
        totalStudyTime: user.totalStudyTime + session.duration,
        totalExp: user.totalExp + session.expGained,
      );
      _monster = monster.withAddedExp(session.expGained);
    });

    await _saveState();
  }

  void _openMonster(BuildContext context) {
    final Monster? monster = _monster;
    if (monster == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MonsterScreen(monster: monster, sessions: _sessions),
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

  Future<void> _signIn(String email, String password) async {
    await widget.authService.signInWithEmail(email: email, password: password);
  }

  Future<void> _signUp(String email, String password) async {
    await widget.authService.signUpWithEmail(email: email, password: password);
  }

  Future<void> _signOut() async {
    await widget.authService.signOut();
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
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!widget.authService.isConfigured) {
      return const SupabaseConfigRequiredScreen();
    }

    if (!_authStatus.isSignedIn) {
      return AuthScreen(onSignIn: _signIn, onSignUp: _signUp);
    }

    if (_isLoadingState || _user == null || _monster == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Builder(
      builder: (context) {
        return HomeScreen(
          monster: _monster!,
          todayStudyTime: _calculateTodayStudyTime(),
          onStartStudy: () => _startStudyFlow(context),
          onOpenMonster: () => _openMonster(context),
          onOpenPlanner: () => _openPlanner(context),
          onSignOut: _signOut,
        );
      },
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
