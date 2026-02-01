import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- Additional Mock Classes for E2E ----

class MockGoTrueClient extends Mock implements GoTrueClient {
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  void emitAuthState(AuthChangeEvent event, Session? session) {
    _authStateController.add(AuthState(event, session));
  }

  // ignore: annotate_overrides
  void dispose() {
    _authStateController.close();
  }
}

class FakeUser extends Fake implements User {
  @override
  String get id => 'test-user-id-123';

  @override
  String get email => 'test@example.com';

  @override
  Map<String, dynamic> get userMetadata => {
        'display_name': 'Test User',
        'avatar_url': null,
      };

  @override
  String get aud => 'authenticated';

  @override
  String get createdAt => '2026-01-15T10:30:00.000Z';
}

class FakeSession extends Fake implements Session {
  @override
  String get accessToken => 'fake-access-token';

  @override
  String get tokenType => 'bearer';

  @override
  User get user => FakeUser();
}

// ---- Pre-configured Mock Setup Functions ----

/// Set up mocks for a logged-out state
void setupLoggedOutMocks(MockGoTrueClient mockAuth) {
  when(() => mockAuth.currentUser).thenReturn(null);
  when(() => mockAuth.currentSession).thenReturn(null);
}

/// Set up mocks for a logged-in state
void setupLoggedInMocks(MockGoTrueClient mockAuth) {
  when(() => mockAuth.currentUser).thenReturn(FakeUser());
  when(() => mockAuth.currentSession).thenReturn(FakeSession());
}
