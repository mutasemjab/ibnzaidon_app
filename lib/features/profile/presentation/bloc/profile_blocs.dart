import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ibnzaidon/features/profile/domain/entities/profile.dart';
import 'package:ibnzaidon/features/profile/domain/usecases/profile_usecases.dart';

class ProfileBloc extends ResourceBloc<Profile> {
  ProfileBloc(this._getProfile);

  final GetProfileUseCase _getProfile;

  @override
  Future<Either<Failure, Profile>> load() => _getProfile(const NoParams());
}

final class ProfileSaveState extends Equatable {
  const ProfileSaveState({
    this.status = SubmissionStatus.idle,
    this.profile,
    this.failure,
  });

  final SubmissionStatus status;
  final Profile? profile;
  final Failure? failure;

  @override
  List<Object?> get props => [status, profile, failure];
}

final class ProfileSaveRequested extends Equatable {
  const ProfileSaveRequested(this.update);

  final ProfileUpdate update;

  @override
  List<Object?> get props => [update];
}

/// Edit profile (fields + avatar).
class ProfileEditBloc extends Bloc<ProfileSaveRequested, ProfileSaveState> {
  ProfileEditBloc(this._updateProfile) : super(const ProfileSaveState()) {
    on<ProfileSaveRequested>(_onSave, transformer: droppable());
  }

  final UpdateProfileUseCase _updateProfile;

  Future<void> _onSave(
    ProfileSaveRequested event,
    Emitter<ProfileSaveState> emit,
  ) async {
    emit(const ProfileSaveState(status: SubmissionStatus.submitting));
    final result = await _updateProfile(event.update);
    emit(
      result.fold(
        (failure) => ProfileSaveState(
          status: SubmissionStatus.failure,
          failure: failure,
        ),
        (profile) => ProfileSaveState(
          status: SubmissionStatus.success,
          profile: profile,
        ),
      ),
    );
  }
}

final class PasswordChangeRequested extends Equatable {
  const PasswordChangeRequested(this.params);

  final ChangePasswordParams params;

  @override
  List<Object?> get props => [
    params.currentPassword,
    params.newPassword,
    params.confirmation,
  ];
}

final class PasswordChangeState extends Equatable {
  const PasswordChangeState({
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final SubmissionStatus status;
  final Failure? failure;

  @override
  List<Object?> get props => [status, failure];
}

class PasswordChangeBloc
    extends Bloc<PasswordChangeRequested, PasswordChangeState> {
  PasswordChangeBloc(this._changePassword)
    : super(const PasswordChangeState()) {
    on<PasswordChangeRequested>(_onRequested, transformer: droppable());
  }

  final ChangePasswordUseCase _changePassword;

  Future<void> _onRequested(
    PasswordChangeRequested event,
    Emitter<PasswordChangeState> emit,
  ) async {
    emit(const PasswordChangeState(status: SubmissionStatus.submitting));
    final result = await _changePassword(event.params);
    emit(
      result.fold(
        (failure) => PasswordChangeState(
          status: SubmissionStatus.failure,
          failure: failure,
        ),
        (_) => const PasswordChangeState(status: SubmissionStatus.success),
      ),
    );
  }
}

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

final class LogoutRequested extends AccountEvent {
  const LogoutRequested();
}

final class DeleteAccountRequested extends AccountEvent {
  const DeleteAccountRequested();
}

enum AccountAction { none, loggedOut, deleted }

final class AccountState extends Equatable {
  const AccountState({
    this.status = SubmissionStatus.idle,
    this.completed = AccountAction.none,
    this.failure,
  });

  final SubmissionStatus status;
  final AccountAction completed;
  final Failure? failure;

  @override
  List<Object?> get props => [status, completed, failure];
}

/// Logout and account deletion (App Store requirement).
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required LogoutUseCase logout,
    required DeleteAccountUseCase deleteAccount,
  }) : _logout = logout,
       _deleteAccount = deleteAccount,
       super(const AccountState()) {
    on<LogoutRequested>(_onLogout, transformer: droppable());
    on<DeleteAccountRequested>(_onDelete, transformer: droppable());
  }

  final LogoutUseCase _logout;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountState(status: SubmissionStatus.submitting));
    await _logout(const NoParams());
    emit(
      const AccountState(
        status: SubmissionStatus.success,
        completed: AccountAction.loggedOut,
      ),
    );
  }

  Future<void> _onDelete(
    DeleteAccountRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountState(status: SubmissionStatus.submitting));
    final result = await _deleteAccount(const NoParams());
    emit(
      result.fold(
        (failure) =>
            AccountState(status: SubmissionStatus.failure, failure: failure),
        (_) => const AccountState(
          status: SubmissionStatus.success,
          completed: AccountAction.deleted,
        ),
      ),
    );
  }
}
