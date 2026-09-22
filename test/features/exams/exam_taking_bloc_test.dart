import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/usecases/exams_usecases.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class _MockStart extends Mock implements StartExamUseCase {}

class _MockSubmit extends Mock implements SubmitAttemptUseCase {}

const _exam = Exam(
  id: 1,
  title: 'Quiz',
  durationMinutes: 10,
  totalQuestions: 2,
);

const _questions = [
  Question(
    id: 11,
    text: 'q1',
    options: [
      QuestionOption(id: 111, text: 'a'),
      QuestionOption(id: 112, text: 'b'),
    ],
  ),
  Question(
    id: 12,
    text: 'q2',
    options: [
      QuestionOption(id: 121, text: 'a'),
      QuestionOption(id: 122, text: 'b'),
    ],
  ),
];

ExamAttemptSession _session({
  required DateTime startedAt,
  bool resumed = false,
}) => ExamAttemptSession(
  attemptId: 50,
  startedAt: startedAt,
  detail: const ExamDetail(exam: _exam, questions: _questions),
  resumed: resumed,
);

const _result = ExamResult(
  attemptId: 50,
  score: 1,
  totalMarks: 2,
  percentage: 0.5,
  isPassed: false,
);

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late InMemoryExamDrafts drafts;
  late DateTime clock;

  setUpAll(
    () => registerFallbackValue(
      const SubmitAttemptParams(attemptId: 0, answers: {}),
    ),
  );

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    drafts = InMemoryExamDrafts();
    clock = DateTime(2025, 1, 1, 10);
    when(() => submit(any())).thenAnswer((_) async => right(_result));
  });

  ExamTakingBloc build() => ExamTakingBloc(
    examId: 1,
    startExam: start,
    submitAttempt: submit,
    drafts: ExamDraftUseCases(drafts),
    now: () => clock,
    tickInterval: const Duration(milliseconds: 10),
  );

  Future<ExamTakingBloc> started({ExamAttemptSession? session}) async {
    when(() => start(1)).thenAnswer(
      (_) async => right(session ?? _session(startedAt: clock)),
    );
    final bloc = build()..add(const ExamAttemptStarted());
    await bloc.stream.firstWhere((s) => s.status == ExamTakingStatus.ready);
    return bloc;
  }

  test('starts an attempt with the full duration remaining', () async {
    final bloc = await started();
    expect(bloc.state.remaining, const Duration(minutes: 10));
    expect(bloc.state.questions.length, 2);
    await bloc.close();
  });

  test('answers are autosaved locally on every change', () async {
    final bloc = await started();
    bloc
      ..add(const ExamOptionSelected(questionId: 11, optionId: 112))
      ..add(const ExamQuestionFlagToggled(12))
      ..add(const ExamQuestionSelected(1));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final draft = drafts.load(50)!;
    expect(draft.answers, {11: 112});
    expect(draft.flagged, {12});
    expect(draft.currentIndex, 1);
    await bloc.close();
  });

  test(
    'resumes answers, flags, position and elapsed time after a kill',
    () async {
      drafts.drafts[50] = ExamDraft(
        localStartedAt: clock.subtract(const Duration(minutes: 4)),
        answers: const {11: 111},
        flagged: const {12},
        currentIndex: 1,
      );
      final bloc = await started(
        session: _session(
          startedAt: clock.subtract(const Duration(minutes: 4)),
          resumed: true,
        ),
      );
      expect(bloc.state.answers, {11: 111});
      expect(bloc.state.flagged, {12});
      expect(bloc.state.currentIndex, 1);
      expect(bloc.state.remaining, const Duration(minutes: 6));
      await bloc.close();
    },
  );

  test('ignores a server started_at that is far off (clock skew)', () async {
    final bloc = await started(
      session: _session(
        startedAt: clock.subtract(const Duration(hours: 3)),
        resumed: true,
      ),
    );
    expect(bloc.state.remaining, const Duration(minutes: 10));
    await bloc.close();
  });

  test('auto-submits when the timer reaches zero', () async {
    final bloc = await started();
    bloc.add(const ExamOptionSelected(questionId: 11, optionId: 111));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    clock = clock.add(const Duration(minutes: 11));
    await bloc.stream.firstWhere((s) => s.status == ExamTakingStatus.submitted);

    expect(bloc.state.autoSubmitted, isTrue);
    expect(bloc.state.result, _result);
    final params =
        verify(() => submit(captureAny())).captured.single
            as SubmitAttemptParams;
    expect(params.attemptId, 50);
    expect(params.answers, {11: 111});
    expect(drafts.load(50), isNull, reason: 'draft cleared after submit');
    await bloc.close();
  });

  test('manual submit sends answers once even if tapped twice', () async {
    final bloc = await started();
    bloc
      ..add(const ExamSubmitRequested())
      ..add(const ExamSubmitRequested());
    await bloc.stream.firstWhere((s) => s.status == ExamTakingStatus.submitted);
    verify(() => submit(any())).called(1);
    await bloc.close();
  });

  test('a failed submit keeps the answers and allows retry', () async {
    when(
      () => submit(any()),
    ).thenAnswer((_) async => left(const NetworkFailure()));
    final bloc = await started();
    bloc
      ..add(const ExamOptionSelected(questionId: 12, optionId: 121))
      ..add(const ExamSubmitRequested());
    await bloc.stream.firstWhere((s) => s.submitFailed);
    expect(bloc.state.status, ExamTakingStatus.ready);
    expect(bloc.state.answers, {12: 121});
    expect(drafts.load(50), isNotNull);

    when(() => submit(any())).thenAnswer((_) async => right(_result));
    bloc.add(const ExamSubmitRequested());
    await bloc.stream.firstWhere((s) => s.status == ExamTakingStatus.submitted);
    await bloc.close();
  });

  test('reports the unanswered count', () async {
    final bloc = await started();
    bloc.add(const ExamOptionSelected(questionId: 11, optionId: 111));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state.unansweredCount, 1);
    await bloc.close();
  });

  test('a start failure is surfaced', () async {
    when(
      () => start(1),
    ).thenAnswer((_) async => left(const ForbiddenFailure()));
    final bloc = build()..add(const ExamAttemptStarted());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ExamTakingStatus.failure,
    );
    expect(state.failure, const ForbiddenFailure());
    await bloc.close();
  });
}
