import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRestore extends Mock implements RestoreSessionUseCase {}

class _MockClear extends Mock implements ClearLocalSessionUseCase {}

const _student = Student(id: 1, name: 'Sara', phone: '0790000000');

void main() {
  late _MockRestore restore;
  late _MockClear clear;
  late SessionExpiryNotifier notifier;

  setUp(() {
    restore = _MockRestore();
    clear = _MockClear();
    notifier = SessionExpiryNotifier();
    when(() => clear()).thenAnswer((_) async {});
  });

  tearDown(() => notifier.dispose());

  AuthBloc build() => AuthBloc(
    restoreSession: restore,
    clearLocalSession: clear,
    sessionExpiry: notifier,
  );

  blocTest<AuthBloc, AuthState>(
    'restores a stored session',
    build: () {
      when(() => restore()).thenAnswer((_) async => _student);
      return build();
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, student: _student),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'is unauthenticated when there is no session',
    build: () {
      when(() => restore()).thenAnswer((_) async => null);
      return build();
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthBloc, AuthState>(
    'a server 401 resets the session and flags "session expired"',
    build: build,
    seed: () =>
        const AuthState(status: AuthStatus.authenticated, student: _student),
    act: (bloc) => notifier.notifyExpired(),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      const AuthState(status: AuthStatus.unauthenticated, sessionExpired: true),
    ],
    verify: (_) => verify(() => clear()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'session expiry while signed out is ignored',
    build: build,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => notifier.notifyExpired(),
    wait: const Duration(milliseconds: 50),
    expect: () => <AuthState>[],
  );

  blocTest<AuthBloc, AuthState>(
    'logging in clears the expired flag',
    build: build,
    seed: () => const AuthState(
      status: AuthStatus.unauthenticated,
      sessionExpired: true,
    ),
    act: (bloc) => bloc.add(const AuthSessionStarted(_student)),
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, student: _student),
    ],
  );
}
