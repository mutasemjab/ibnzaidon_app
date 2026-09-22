import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.student,
    this.sessionExpired = false,
  });

  final AuthStatus status;
  final Student? student;

  /// Set when the server rejected the token; the login page shows a
  /// friendly "session expired" notice.
  final bool sessionExpired;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, student, sessionExpired];
}

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSessionStarted extends AuthEvent {
  const AuthSessionStarted(this.student);

  final Student student;

  @override
  List<Object?> get props => [student];
}

final class AuthStudentUpdated extends AuthEvent {
  const AuthStudentUpdated(this.student);

  final Student student;

  @override
  List<Object?> get props => [student];
}

final class AuthSessionEnded extends AuthEvent {
  const AuthSessionEnded();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

/// Global session bloc: the single source of truth for "who is signed in".
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required RestoreSessionUseCase restoreSession,
    required ClearLocalSessionUseCase clearLocalSession,
    required SessionExpiryNotifier sessionExpiry,
  }) : _restoreSession = restoreSession,
       _clearLocalSession = clearLocalSession,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSessionStarted>(
      (event, emit) => emit(
        AuthState(status: AuthStatus.authenticated, student: event.student),
      ),
    );
    on<AuthStudentUpdated>(
      (event, emit) => emit(
        AuthState(status: AuthStatus.authenticated, student: event.student),
      ),
    );
    on<AuthSessionEnded>(
      (event, emit) =>
          emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
    on<AuthSessionExpired>(_onExpired);
    _expirySubscription = sessionExpiry.stream.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final RestoreSessionUseCase _restoreSession;
  final ClearLocalSessionUseCase _clearLocalSession;
  late final StreamSubscription<void> _expirySubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final student = await _restoreSession();
    emit(
      student == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, student: student),
    );
  }

  Future<void> _onExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isAuthenticated) return;
    await _clearLocalSession();
    emit(
      const AuthState(status: AuthStatus.unauthenticated, sessionExpired: true),
    );
  }

  @override
  Future<void> close() async {
    await _expirySubscription.cancel();
    return super.close();
  }
}
