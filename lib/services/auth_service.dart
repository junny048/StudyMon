import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthStatus {
  const AuthStatus({required this.isSignedIn, this.userId, this.email});

  final bool isSignedIn;
  final String? userId;
  final String? email;

  static const AuthStatus signedOut = AuthStatus(isSignedIn: false);
}

abstract class AuthService {
  bool get isConfigured;
  AuthStatus get currentStatus;
  Stream<AuthStatus> get authStatusChanges;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService({required this.isConfigured});

  @override
  final bool isConfigured;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  AuthStatus get currentStatus {
    if (!isConfigured) {
      return AuthStatus.signedOut;
    }

    final User? user = _client.auth.currentUser;
    if (user == null) {
      return AuthStatus.signedOut;
    }

    return AuthStatus(isSignedIn: true, userId: user.id, email: user.email);
  }

  @override
  Stream<AuthStatus> get authStatusChanges {
    if (!isConfigured) {
      return Stream<AuthStatus>.value(AuthStatus.signedOut);
    }

    return _client.auth.onAuthStateChange.map((event) {
      final User? user = event.session?.user;
      if (user == null) {
        return AuthStatus.signedOut;
      }

      return AuthStatus(isSignedIn: true, userId: user.id, email: user.email);
    });
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      throw const AuthException('Supabase is not configured.');
    }

    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      throw const AuthException('Supabase is not configured.');
    }

    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured) {
      return;
    }

    await _client.auth.signOut();
  }
}
