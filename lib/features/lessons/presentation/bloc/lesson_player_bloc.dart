import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/features/lessons/domain/entities/lesson.dart';
import 'package:ibnzaidon/features/lessons/domain/usecases/lessons_usecases.dart';

final class LessonPlayerState extends Equatable {
  const LessonPlayerState({
    this.status = ResourceStatus.initial,
    this.lesson,
    this.units,
    this.resumeSeconds = 0,
    this.isCompleted = false,
    this.coursePercentage,
    this.failure,
  });

  final ResourceStatus status;
  final Lesson? lesson;
  final CourseUnits? units;
  final int resumeSeconds;
  final bool isCompleted;
  final double? coursePercentage;
  final Failure? failure;

  bool get isLoading =>
      status == ResourceStatus.initial || status == ResourceStatus.loading;

  bool get isForbidden => failure is ForbiddenFailure;

  List<UnitLesson> get _ordered => units?.orderedLessons ?? const [];

  int get _index =>
      _ordered.indexWhere((candidate) => candidate.id == lesson?.id);

  UnitLesson? get previousLesson {
    final index = _index;
    return index > 0 ? _ordered[index - 1] : null;
  }

  UnitLesson? get nextLesson {
    final index = _index;
    return index >= 0 && index < _ordered.length - 1
        ? _ordered[index + 1]
        : null;
  }

  LessonPlayerState copyWith({
    ResourceStatus? status,
    Lesson? lesson,
    CourseUnits? units,
    int? resumeSeconds,
    bool? isCompleted,
    double? coursePercentage,
    Failure? failure,
    bool clearFailure = false,
  }) => LessonPlayerState(
    status: status ?? this.status,
    lesson: lesson ?? this.lesson,
    units: units ?? this.units,
    resumeSeconds: resumeSeconds ?? this.resumeSeconds,
    isCompleted: isCompleted ?? this.isCompleted,
    coursePercentage: coursePercentage ?? this.coursePercentage,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    lesson,
    units,
    resumeSeconds,
    isCompleted,
    coursePercentage,
    failure,
  ];
}

sealed class LessonPlayerEvent extends Equatable {
  const LessonPlayerEvent();

  @override
  List<Object?> get props => [];
}

final class LessonRequested extends LessonPlayerEvent {
  const LessonRequested();
}

/// Emitted continuously by the player; the bloc throttles server reports.
final class LessonPositionChanged extends LessonPlayerEvent {
  const LessonPositionChanged(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

final class LessonPlaybackEnded extends LessonPlayerEvent {
  const LessonPlaybackEnded();
}

/// "Mark as complete" (PDF lessons) or manual completion.
final class LessonMarkedComplete extends LessonPlayerEvent {
  const LessonMarkedComplete();
}

class LessonPlayerBloc extends Bloc<LessonPlayerEvent, LessonPlayerState> {
  LessonPlayerBloc({
    required this.courseId,
    required this.lessonId,
    required GetLessonUseCase getLesson,
    required ReportLessonProgressUseCase reportProgress,
    required GetCourseUnitsUseCase getCourseUnits,
    required GetCourseProgressUseCase getCourseProgress,
  }) : _getLesson = getLesson,
       _reportProgress = reportProgress,
       _getCourseUnits = getCourseUnits,
       _getCourseProgress = getCourseProgress,
       super(const LessonPlayerState()) {
    on<LessonRequested>(_onRequested, transformer: restartable());
    on<LessonPositionChanged>(_onPosition, transformer: sequential());
    on<LessonPlaybackEnded>(_onEnded, transformer: droppable());
    on<LessonMarkedComplete>(_onMarkedComplete, transformer: droppable());
  }

  /// Seconds between progress reports while playing.
  static const reportInterval = 30;

  final int courseId;
  final int lessonId;
  final GetLessonUseCase _getLesson;
  final ReportLessonProgressUseCase _reportProgress;
  final GetCourseUnitsUseCase _getCourseUnits;
  final GetCourseProgressUseCase _getCourseProgress;

  int _lastReportedSeconds = 0;
  int _latestSeconds = 0;

  Future<void> _onRequested(
    LessonRequested event,
    Emitter<LessonPlayerState> emit,
  ) async {
    emit(const LessonPlayerState(status: ResourceStatus.loading));
    final lessonResult = await _getLesson(lessonId);
    if (emit.isDone) return;
    final lesson = lessonResult.toNullable();
    if (lesson == null) {
      emit(
        LessonPlayerState(
          status: ResourceStatus.failure,
          failure: lessonResult.getLeft().toNullable(),
        ),
      );
      return;
    }
    final results = await Future.wait([
      _getCourseUnits(courseId),
      _getCourseProgress(courseId),
    ]);
    if (emit.isDone) return;
    final units = (results[0] as Either<Failure, CourseUnits>).toNullable();
    final progress = (results[1] as Either<Failure, CourseProgress>)
        .toNullable();
    final position = progress?.watchPositions[lessonId];
    final completed =
        position?.isCompleted ??
        progress?.completedLessonIds.contains(lessonId) ??
        false;
    _lastReportedSeconds = position?.watchSeconds ?? 0;
    _latestSeconds = _lastReportedSeconds;
    emit(
      LessonPlayerState(
        status: ResourceStatus.success,
        lesson: lesson,
        units: units,
        resumeSeconds: completed ? 0 : position?.watchSeconds ?? 0,
        isCompleted: completed,
        coursePercentage: progress?.percentage,
      ),
    );
  }

  Future<void> _onPosition(
    LessonPositionChanged event,
    Emitter<LessonPlayerState> emit,
  ) async {
    _latestSeconds = event.seconds;
    if (event.seconds - _lastReportedSeconds < reportInterval) return;
    _lastReportedSeconds = event.seconds;
    await _reportProgress(
      LessonProgressUpdate(lessonId: lessonId, watchSeconds: event.seconds),
    );
  }

  Future<void> _onEnded(
    LessonPlaybackEnded event,
    Emitter<LessonPlayerState> emit,
  ) => _complete(emit, watchSeconds: _latestSeconds);

  Future<void> _onMarkedComplete(
    LessonMarkedComplete event,
    Emitter<LessonPlayerState> emit,
  ) => _complete(emit);

  Future<void> _complete(
    Emitter<LessonPlayerState> emit, {
    int? watchSeconds,
  }) async {
    if (state.isCompleted) return;
    final result = await _reportProgress(
      LessonProgressUpdate(
        lessonId: lessonId,
        watchSeconds: watchSeconds,
        isCompleted: true,
      ),
    );
    if (emit.isDone) return;
    result.fold(
      (_) {},
      (progress) => emit(
        state.copyWith(
          isCompleted: true,
          coursePercentage: progress.coursePercentage,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    // Flush the last position so "resume" is accurate after leaving.
    if (_latestSeconds > _lastReportedSeconds && !state.isCompleted) {
      unawaited(
        _reportProgress(
          LessonProgressUpdate(
            lessonId: lessonId,
            watchSeconds: _latestSeconds,
          ),
        ),
      );
    }
    return super.close();
  }
}
