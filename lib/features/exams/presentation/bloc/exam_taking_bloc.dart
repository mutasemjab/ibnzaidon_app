import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/usecases/exams_usecases.dart';

import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_event.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_state.dart';

export 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_event.dart';
export 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_state.dart';

class ExamTakingBloc extends Bloc<ExamTakingEvent, ExamTakingState> {
  ExamTakingBloc({
    required this.examId,
    required StartExamUseCase startExam,
    required SubmitAttemptUseCase submitAttempt,
    required ExamDraftUseCases drafts,
    DateTime Function() now = DateTime.now,
    this.tickInterval = const Duration(seconds: 1),
  }) : _startExam = startExam,
       _submitAttempt = submitAttempt,
       _drafts = drafts,
       _now = now,
       super(const ExamTakingState()) {
    on<ExamAttemptStarted>(_onStarted, transformer: droppable());
    on<ExamOptionSelected>(_onOptionSelected, transformer: sequential());
    on<ExamAnswerCleared>(_onAnswerCleared, transformer: sequential());
    on<ExamQuestionFlagToggled>(_onFlagToggled, transformer: sequential());
    on<ExamQuestionSelected>(_onQuestionSelected, transformer: sequential());
    on<ExamSubmitRequested>(_onSubmit, transformer: droppable());
    on<ExamTicked>(_onTicked, transformer: sequential());
  }

  final int examId;
  final StartExamUseCase _startExam;
  final SubmitAttemptUseCase _submitAttempt;
  final ExamDraftUseCases _drafts;
  final DateTime Function() _now;
  final Duration tickInterval;

  Timer? _timer;
  DateTime? _deadline;

  /// A server `started_at` further than this from the device clock is
  /// treated as clock/timezone skew and ignored.
  static const _maxPlausibleSkew = Duration(minutes: 2);

  Future<void> _onStarted(
    ExamAttemptStarted event,
    Emitter<ExamTakingState> emit,
  ) async {
    emit(const ExamTakingState());
    final result = await _startExam(examId);
    if (emit.isDone) return;
    final session = result.toNullable();
    if (session == null) {
      emit(
        ExamTakingState(
          status: ExamTakingStatus.failure,
          failure: result.getLeft().toNullable(),
        ),
      );
      return;
    }
    final duration = session.detail.exam.duration;
    final draft = _drafts.load(session.attemptId);
    final localStart =
        draft?.localStartedAt ?? _resolveStart(session, duration);
    _deadline = localStart.add(duration);
    final questionIds = session.detail.questions.map((q) => q.id).toSet();
    final answers = <int, int>{
      for (final entry in (draft?.answers ?? const <int, int>{}).entries)
        if (questionIds.contains(entry.key)) entry.key: entry.value,
    };
    final index = (draft?.currentIndex ?? 0).clamp(
      0,
      session.detail.questions.isEmpty
          ? 0
          : session.detail.questions.length - 1,
    );
    emit(
      ExamTakingState(
        status: ExamTakingStatus.ready,
        session: session,
        answers: answers,
        flagged: draft?.flagged ?? const {},
        currentIndex: index,
        remaining: _remaining(),
      ),
    );
    await _persist(localStart);
    _startTimer();
    if (_remaining() <= Duration.zero) {
      add(const ExamSubmitRequested(auto: true));
    }
  }

  DateTime _resolveStart(ExamAttemptSession session, Duration duration) {
    final now = _now();
    final serverStart = session.startedAt;
    if (!session.resumed || serverStart == null) return now;
    final elapsed = now.difference(serverStart);
    final plausible =
        elapsed >= -_maxPlausibleSkew &&
        elapsed <= duration + _maxPlausibleSkew;
    return plausible ? serverStart : now;
  }

  Duration _remaining() {
    final deadline = _deadline;
    if (deadline == null) return Duration.zero;
    final left = deadline.difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  void _startTimer() {
    _timer?.cancel();
    // The student may have left the screen while the attempt was starting.
    if (isClosed) return;
    _timer = Timer.periodic(tickInterval, (_) {
      if (!isClosed) add(const ExamTicked());
    });
  }

  void _onTicked(ExamTicked event, Emitter<ExamTakingState> emit) {
    if (state.status != ExamTakingStatus.ready) return;
    final remaining = _remaining();
    emit(state.copyWith(remaining: remaining));
    if (remaining <= Duration.zero) {
      _timer?.cancel();
      add(const ExamSubmitRequested(auto: true));
    }
  }

  Future<void> _onOptionSelected(
    ExamOptionSelected event,
    Emitter<ExamTakingState> emit,
  ) async {
    if (state.status != ExamTakingStatus.ready) return;
    emit(
      state.copyWith(
        answers: {...state.answers, event.questionId: event.optionId},
      ),
    );
    await _persist();
  }

  Future<void> _onAnswerCleared(
    ExamAnswerCleared event,
    Emitter<ExamTakingState> emit,
  ) async {
    if (state.status != ExamTakingStatus.ready) return;
    emit(state.copyWith(answers: {...state.answers}..remove(event.questionId)));
    await _persist();
  }

  Future<void> _onFlagToggled(
    ExamQuestionFlagToggled event,
    Emitter<ExamTakingState> emit,
  ) async {
    final flagged = {...state.flagged};
    if (!flagged.add(event.questionId)) flagged.remove(event.questionId);
    emit(state.copyWith(flagged: flagged));
    await _persist();
  }

  Future<void> _onQuestionSelected(
    ExamQuestionSelected event,
    Emitter<ExamTakingState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.questions.length) return;
    emit(state.copyWith(currentIndex: event.index));
    await _persist();
  }

  Future<void> _onSubmit(
    ExamSubmitRequested event,
    Emitter<ExamTakingState> emit,
  ) async {
    final session = state.session;
    if (session == null || state.isSubmitting) return;
    if (state.status == ExamTakingStatus.submitted) return;
    _timer?.cancel();
    emit(
      state.copyWith(
        status: ExamTakingStatus.submitting,
        autoSubmitted: event.auto || state.autoSubmitted,
        submitFailed: false,
        clearFailure: true,
      ),
    );
    final result = await _submitAttempt(
      SubmitAttemptParams(attemptId: session.attemptId, answers: state.answers),
    );
    if (emit.isDone) return;
    final examResult = result.toNullable();
    if (examResult == null) {
      emit(
        state.copyWith(
          status: ExamTakingStatus.ready,
          failure: result.getLeft().toNullable(),
          submitFailed: true,
        ),
      );
      return;
    }
    await _drafts.clear(session.attemptId);
    emit(
      state.copyWith(status: ExamTakingStatus.submitted, result: examResult),
    );
  }

  Future<void> _persist([DateTime? localStart]) async {
    final session = state.session;
    if (session == null) return;
    final existing = _drafts.load(session.attemptId);
    final start =
        localStart ??
        existing?.localStartedAt ??
        _deadline?.subtract(state.totalDuration) ??
        _now();
    await _drafts.save(
      session.attemptId,
      ExamDraft(
        localStartedAt: start,
        answers: state.answers,
        flagged: state.flagged,
        currentIndex: state.currentIndex,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
