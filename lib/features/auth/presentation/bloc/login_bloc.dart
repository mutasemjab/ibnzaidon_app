import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/storage/app_flow_store.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.phone, required this.password});

  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone];
}

final class LoginGuestChosen extends LoginEvent {
  const LoginGuestChosen();
}

final class LoginState extends Equatable {
  const LoginState({
    this.status = SubmissionStatus.idle,
    this.student,
    this.failure,
    this.guestChosen = false,
  });

  final SubmissionStatus status;
  final Student? student;
  final Failure? failure;
  final bool guestChosen;

  @override
  List<Object?> get props => [status, student, failure, guestChosen];
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login, this._flowStore) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
    on<LoginGuestChosen>(_onGuestChosen, transformer: droppable());
  }

  final LoginUseCase _login;
  final AppFlowStore _flowStore;

  Future<void> _onGuestChosen(
    LoginGuestChosen event,
    Emitter<LoginState> emit,
  ) async {
    await _flowStore.setGuestChosen(value: true);
    emit(const LoginState(guestChosen: true));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState(status: SubmissionStatus.submitting));
    final result = await _login(
      LoginParams(phone: event.phone, password: event.password),
    );
    emit(
      result.fold(
        (failure) =>
            LoginState(status: SubmissionStatus.failure, failure: failure),
        (student) =>
            LoginState(status: SubmissionStatus.success, student: student),
      ),
    );
  }
}
