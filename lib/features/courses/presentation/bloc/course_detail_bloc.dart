import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';

final class CourseDetailState extends Equatable {
  const CourseDetailState({
    this.status = ResourceStatus.initial,
    this.detail,
    this.units,
    this.progress,
    this.failure,
    this.unitsResolved = false,
  });

  final ResourceStatus status;
  final CourseDetail? detail;

  /// Lock-aware lessons; `null` for guests or when the call failed.
  final CourseUnits? units;
  final CourseProgress? progress;
  final Failure? failure;

  /// `true` once the lock-aware `units` follow-up call has finished (whether
  /// it succeeded or not). The public `courses/{id}` response doesn't always
  /// carry `is_enrolled`, so the true enrollment status is only known after
  /// this — the action bar uses it to avoid flashing "Activate" for a split
  /// second on a course the student already owns.
  final bool unitsResolved;

  bool get isLoading =>
      status == ResourceStatus.initial || status == ResourceStatus.loading;

  bool get isEnrolled =>
      (units?.isEnrolled ?? false) || (detail?.isEnrolled ?? false);

  double get progressFraction => progress?.percentage ?? detail?.progress ?? 0;

  /// First unlocked lesson the student has not completed (fallback: first).
  UnitLesson? get nextLesson {
    final lessons = units?.orderedLessons ?? const <UnitLesson>[];
    if (lessons.isEmpty) return null;
    final completed = progress?.completedLessonIds ?? const <int>{};
    for (final lesson in lessons) {
      if (!completed.contains(lesson.id) &&
          !lesson.isLocked &&
          !lesson.isLockedBySequence) {
        return lesson;
      }
    }
    return lessons.first;
  }

  CourseDetailState copyWith({
    ResourceStatus? status,
    CourseDetail? detail,
    CourseUnits? units,
    CourseProgress? progress,
    Failure? failure,
    bool clearFailure = false,
    bool clearUnits = false,
    bool? unitsResolved,
  }) => CourseDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    units: clearUnits ? null : units ?? this.units,
    progress: progress ?? this.progress,
    failure: clearFailure ? null : failure ?? this.failure,
    unitsResolved: unitsResolved ?? this.unitsResolved,
  );

  @override
  List<Object?> get props => [
    status,
    detail,
    units,
    progress,
    failure,
    unitsResolved,
  ];
}

sealed class CourseDetailEvent {
  const CourseDetailEvent();
}

final class CourseDetailRequested extends CourseDetailEvent {
  const CourseDetailRequested();
}

final class CourseDetailRefreshed extends CourseDetailEvent {
  const CourseDetailRefreshed();
}

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc({
    required this.courseId,
    required GetCourseDetailUseCase getCourseDetail,
    required GetCourseUnitsUseCase getCourseUnits,
    required GetCourseProgressUseCase getCourseProgress,
  }) : _getCourseDetail = getCourseDetail,
       _getCourseUnits = getCourseUnits,
       _getCourseProgress = getCourseProgress,
       super(const CourseDetailState()) {
    on<CourseDetailRequested>(
      (event, emit) => _load(emit, showLoading: true),
      transformer: restartable(),
    );
    on<CourseDetailRefreshed>(
      (event, emit) => _load(emit, showLoading: state.detail == null),
      transformer: restartable(),
    );
    _localeSubscription = LocaleChanges.stream.listen((_) {
      if (!isLoadingInitially) add(const CourseDetailRefreshed());
    });
  }

  late final StreamSubscription<String> _localeSubscription;

  bool get isLoadingInitially => state.status == ResourceStatus.initial;

  @override
  Future<void> close() async {
    await _localeSubscription.cancel();
    return super.close();
  }

  final int courseId;
  final GetCourseDetailUseCase _getCourseDetail;
  final GetCourseUnitsUseCase _getCourseUnits;
  final GetCourseProgressUseCase _getCourseProgress;

  Future<void> _load(
    Emitter<CourseDetailState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: ResourceStatus.loading,
          clearFailure: true,
          unitsResolved: false,
        ),
      );
    }
    final detailResult = await _getCourseDetail(courseId);
    if (emit.isDone) return;
    final detail = detailResult.toNullable();
    if (detail == null) {
      emit(
        state.copyWith(
          status: ResourceStatus.failure,
          failure: detailResult.getLeft().toNullable(),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ResourceStatus.success,
        detail: detail,
        clearFailure: true,
      ),
    );

    // Lock-aware lessons and progress are best effort: guests get a 401 and
    // simply keep the public outline.
    final unitsResult = await _getCourseUnits(courseId);
    final progressResult =
        detail.isEnrolled || (unitsResult.toNullable()?.isEnrolled ?? false)
        ? await _getCourseProgress(courseId)
        : null;
    if (emit.isDone) return;
    emit(
      state.copyWith(
        units: unitsResult.toNullable(),
        progress: progressResult?.toNullable(),
        unitsResolved: true,
      ),
    );
  }
}
