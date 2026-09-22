import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted(this.params);

  final RegisterParams params;

  @override
  List<Object?> get props => [params];
}

final class RegisterState extends Equatable {
  const RegisterState({
    this.status = SubmissionStatus.idle,
    this.student,
    this.failure,
  });

  final SubmissionStatus status;
  final Student? student;
  final Failure? failure;

  @override
  List<Object?> get props => [status, student, failure];
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._register) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onSubmitted, transformer: droppable());
  }

  final RegisterUseCase _register;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterState(status: SubmissionStatus.submitting));
    final result = await _register(event.params);
    emit(
      result.fold(
        (failure) =>
            RegisterState(status: SubmissionStatus.failure, failure: failure),
        (student) =>
            RegisterState(status: SubmissionStatus.success, student: student),
      ),
    );
  }
}
