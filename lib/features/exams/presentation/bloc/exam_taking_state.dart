import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';

enum ExamTakingStatus { loading, ready, submitting, submitted, failure }

final class ExamTakingState extends Equatable {
  const ExamTakingState({
    this.status = ExamTakingStatus.loading,
    this.session,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    this.remaining = Duration.zero,
    this.result,
    this.failure,
    this.submitFailed = false,
    this.autoSubmitted = false,
  });

  final ExamTakingStatus status;
  final ExamAttemptSession? session;

  /// question id -> chosen option id
  final Map<int, int> answers;
  final Set<int> flagged;
  final int currentIndex;
  final Duration remaining;
  final ExamResult? result;
  final Failure? failure;

  /// A submit was attempted and failed; the student can retry.
  final bool submitFailed;

  /// The submit was triggered by the timer reaching zero.
  final bool autoSubmitted;

  List<Question> get questions => session?.detail.questions ?? const [];
  Question? get currentQuestion =>
      currentIndex >= 0 && currentIndex < questions.length
      ? questions[currentIndex]
      : null;
  int get unansweredCount =>
      questions.where((q) => !answers.containsKey(q.id)).length;
  Duration get totalDuration => session?.detail.exam.duration ?? Duration.zero;
  bool get isSubmitting => status == ExamTakingStatus.submitting;

  ExamTakingState copyWith({
    ExamTakingStatus? status,
    ExamAttemptSession? session,
    Map<int, int>? answers,
    Set<int>? flagged,
    int? currentIndex,
    Duration? remaining,
    ExamResult? result,
    Failure? failure,
    bool clearFailure = false,
    bool? submitFailed,
    bool? autoSubmitted,
  }) => ExamTakingState(
    status: status ?? this.status,
    session: session ?? this.session,
    answers: answers ?? this.answers,
    flagged: flagged ?? this.flagged,
    currentIndex: currentIndex ?? this.currentIndex,
    remaining: remaining ?? this.remaining,
    result: result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
    submitFailed: submitFailed ?? this.submitFailed,
    autoSubmitted: autoSubmitted ?? this.autoSubmitted,
  );

  @override
  List<Object?> get props => [
    status,
    session,
    answers,
    flagged,
    currentIndex,
    remaining,
    result,
    failure,
    submitFailed,
    autoSubmitted,
  ];
}
