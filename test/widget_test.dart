import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymon/main.dart';
import 'package:studymon/services/auth_service.dart';

class _FakeSignedInAuthService implements AuthService {
  @override
  Stream<AuthStatus> get authStatusChanges =>
      Stream<AuthStatus>.value(currentStatus);

  @override
  AuthStatus get currentStatus => const AuthStatus(
    isSignedIn: true,
    userId: 'u-test',
    email: 'test@studymon.app',
  );

  @override
  bool get isConfigured => true;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home screen renders StudyMon and Start Study button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      StudyMonApp(authService: _FakeSignedInAuthService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('StudyMon'), findsOneWidget);
    expect(find.text('Start Study'), findsOneWidget);
    expect(find.textContaining('Today Study Time'), findsOneWidget);
  });
}
