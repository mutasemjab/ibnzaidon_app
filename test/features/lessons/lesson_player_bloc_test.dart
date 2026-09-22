import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/features/lessons/domain/entities/lesson.dart';
import 'package:ibnzaidon/features/lessons/domain/usecases/lessons_usecases.dart';
import 'package:ibnzaidon/features/lessons/presentation/bloc/lesson_player_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLesson extends Mock implements GetLessonUseCase {}

class _MockReport extends Mock implements ReportLessonProgressUseCase {}

class _MockUnits extends Mock implements GetCourseUnitsUseCase {}

class _MockProgress extends Mock implements GetCourseProgressUseCase {}

const _lesson = Lesson(
  id: 2,
  title: 'Lesson 2',
  type: LessonType.video,
  videoUrl: 'https://youtu.be/abcdefghijk',
  courseId: 1,
);

const _units = CourseUnits(
  courseId: 1,
  courseName: 'c',
  isEnrolled: true,
  units: [
    CourseUnit(
      id: 1,
      title: 'u',
      orderIndex: 1,
      lessons: [
        UnitLesson(id: 1, title: 'one', type: LessonType.video),
        UnitLesson(id: 2, title: 'two', type: LessonType.video),
        UnitLesson(id: 3, title: 'three', type: LessonType.pdf, isLocked: true),
      ],
    ),
  ],
);

void main() {
  late _MockGetLesson getLesson;
  late _MockReport report;
  late _MockUnits units;
  late _MockProgress progress;

  setUpAll(
    () => registerFallbackValue(const LessonProgressUpdate(lessonId: 0)),
  );

  setUp(() {
    getLesson = _MockGetLesson();
    report = _MockReport();
    units = _MockUnits();
    progress = _MockProgress();
    when(() => getLesson(2)).thenAnswer((_) async => right(_lesson));
    when(() => units(1)).thenAnswer((_) async => right(_units));
    when(() => progress(1)).thenAnswer(
      (_) async => right(
        const CourseProgress(
          percentage: 0.3,
          watchPositions: {
            2: WatchPosition(watchSeconds: 95, isCompleted: false),
          },
        ),
      ),
    );
    when(() => report(any())).thenAnswer(
      (_) async => right(
        const LessonProgressResult(
          lessonId: 2,
          watchSeconds: 0,
          isCompleted: true,
          coursePercentage: 0.5,
        ),
      ),
    );
  });

  LessonPlayerBloc build() => LessonPlayerBloc(
    courseId: 1,
    lessonId: 2,
    getLesson: getLesson,
    reportProgress: report,
    getCourseUnits: units,
    getCourseProgress: progress,
  );

  Future<LessonPlayerBloc> loaded() async {
    final bloc = build()..add(const LessonRequested());
    await bloc.stream.firstWhere((s) => s.status == ResourceStatus.success);
    return bloc;
  }

  test('loads the lesson, resume position and neighbours', () async {
    final bloc = await loaded();
    expect(bloc.state.lesson, _lesson);
    expect(bloc.state.resumeSeconds, 95);
    expect(bloc.state.previousLesson?.id, 1);
    expect(bloc.state.nextLesson?.id, 3);
    expect(bloc.state.nextLesson?.isLocked, isTrue);
    await bloc.close();
  });

  test('reports watch_seconds at most every 30 seconds', () async {
    final bloc = await loaded();
    bloc
      ..add(const LessonPositionChanged(100)) // +5 since resume: no report
      ..add(const LessonPositionChanged(124)) // +29: no report
      ..add(const LessonPositionChanged(126)) // +31: report
      ..add(const LessonPositionChanged(140)) // +14: no report
      ..add(const LessonPositionChanged(160)); // +34: report
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final updates = verify(
      () => report(captureAny()),
    ).captured.cast<LessonProgressUpdate>();
    expect(updates.map((u) => u.watchSeconds), [126, 160]);
    expect(updates.every((u) => u.isCompleted == null), isTrue);
    await bloc.close();
  });

  test(
    'sends is_completed on playback end and exposes course progress',
    () async {
      final bloc = await loaded();
      bloc.add(const LessonPlaybackEnded());
      final state = await bloc.stream.firstWhere((s) => s.isCompleted);
      expect(state.coursePercentage, 0.5);
      final update =
          verify(() => report(captureAny())).captured.single
              as LessonProgressUpdate;
      expect(update.isCompleted, isTrue);
      await bloc.close();
    },
  );

  test('"mark as complete" (PDF lessons) reports completion once', () async {
    final bloc = await loaded();
    bloc
      ..add(const LessonMarkedComplete())
      ..add(const LessonMarkedComplete());
    await bloc.stream.firstWhere((s) => s.isCompleted);
    verify(() => report(any())).called(1);
    await bloc.close();
  });

  test('a 403 is exposed so the UI can explain why', () async {
    when(() => getLesson(2)).thenAnswer(
      (_) async =>
          left(const ForbiddenFailure(message: 'finish lesson 1 first')),
    );
    final bloc = build()..add(const LessonRequested());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ResourceStatus.failure,
    );
    expect(state.isForbidden, isTrue);
    expect(state.failure?.message, 'finish lesson 1 first');
    await bloc.close();
  });
}
