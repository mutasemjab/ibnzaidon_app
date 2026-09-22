import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/submission_status.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';

final class ActivationSubmitted extends Equatable {
  const ActivationSubmitted(this.cardCode);

  final String cardCode;

  @override
  List<Object?> get props => [cardCode];
}

final class ActivationState extends Equatable {
  const ActivationState({
    this.status = SubmissionStatus.idle,
    this.result,
    this.failure,
  });

  final SubmissionStatus status;
  final ActivationResult? result;
  final Failure? failure;

  @override
  List<Object?> get props => [status, result, failure];
}

/// Card (scratch code) activation for one course.
class ActivationBloc extends Bloc<ActivationSubmitted, ActivationState> {
  ActivationBloc({
    required this.courseId,
    required ActivateCourseUseCase activateCourse,
  }) : _activateCourse = activateCourse,
       super(const ActivationState()) {
    on<ActivationSubmitted>(_onSubmitted, transformer: droppable());
  }

  final int courseId;
  final ActivateCourseUseCase _activateCourse;

  Future<void> _onSubmitted(
    ActivationSubmitted event,
    Emitter<ActivationState> emit,
  ) async {
    emit(const ActivationState(status: SubmissionStatus.submitting));
    final result = await _activateCourse(
      ActivateCourseParams(courseId: courseId, cardCode: event.cardCode),
    );
    emit(
      result.fold(
        (failure) =>
            ActivationState(status: SubmissionStatus.failure, failure: failure),
        (activation) => ActivationState(
          status: SubmissionStatus.success,
          result: activation,
        ),
      ),
    );
  }
}
