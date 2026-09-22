import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCourses extends Mock implements GetCoursesUseCase {}

Course _course(int id) => Course(id: id, title: 'c$id');

PagedList<Course> _page(int page, {int last = 2}) => PagedList(
  items: [_course(page * 10), _course(page * 10 + 1)],
  currentPage: page,
  lastPage: last,
  total: last * 2,
);

void main() {
  late _MockGetCourses getCourses;

  setUpAll(() {
    registerFallbackValue(
      const CoursesPageParams(page: 1, query: CourseQuery()),
    );
  });

  setUp(() {
    getCourses = _MockGetCourses();
    when(() => getCourses(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.first as CoursesPageParams;
      return right(_page(params.page));
    });
  });

  CoursesBloc build() => CoursesBloc(getCourses);

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'loads the first page',
    build: build,
    act: (bloc) => bloc.add(const PagedStarted<CourseQuery>()),
    expect: () => [
      isA<PagedState<Course, CourseQuery>>().having(
        (s) => s.status,
        'status',
        PagedStatus.loading,
      ),
      isA<PagedState<Course, CourseQuery>>()
          .having((s) => s.status, 'status', PagedStatus.success)
          .having((s) => s.items.length, 'items', 2)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isFalse),
    ],
  );

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'appends the next page and stops at the last one',
    build: build,
    act: (bloc) async {
      bloc.add(const PagedStarted<CourseQuery>());
      await bloc.stream.firstWhere((s) => s.status == PagedStatus.success);
      bloc.add(const PagedNextPageRequested<CourseQuery>());
    },
    verify: (bloc) {
      expect(bloc.state.items.length, 4);
      expect(bloc.state.page, 2);
      expect(bloc.state.hasReachedMax, isTrue);
      verify(() => getCourses(any())).called(2);
    },
  );

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'ignores next-page requests once the end is reached',
    build: build,
    seed: () => PagedState<Course, CourseQuery>(
      query: const CourseQuery(),
      status: PagedStatus.success,
      items: [_course(1)],
      page: 2,
      hasReachedMax: true,
    ),
    act: (bloc) => bloc.add(const PagedNextPageRequested<CourseQuery>()),
    expect: () => <PagedState<Course, CourseQuery>>[],
    verify: (_) => verifyNever(() => getCourses(any())),
  );

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'debounces search: rapid keystrokes trigger a single request',
    build: build,
    act: (bloc) async {
      bloc
        ..add(const PagedQueryChanged(CourseQuery(search: 'a'), debounce: true))
        ..add(
          const PagedQueryChanged(CourseQuery(search: 'al'), debounce: true),
        )
        ..add(
          const PagedQueryChanged(CourseQuery(search: 'alg'), debounce: true),
        );
    },
    wait: const Duration(milliseconds: 700),
    verify: (bloc) {
      expect(bloc.state.query.search, 'alg');
      verify(() => getCourses(any())).called(1);
    },
  );

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'refresh keeps existing items while reloading',
    build: build,
    seed: () => PagedState<Course, CourseQuery>(
      query: const CourseQuery(),
      status: PagedStatus.success,
      items: [_course(1)],
      page: 1,
    ),
    act: (bloc) => bloc.add(const PagedRefreshed<CourseQuery>()),
    expect: () => [
      isA<PagedState<Course, CourseQuery>>()
          .having((s) => s.status, 'status', PagedStatus.loading)
          .having((s) => s.items.length, 'kept items', 1),
      isA<PagedState<Course, CourseQuery>>()
          .having((s) => s.status, 'status', PagedStatus.success)
          .having((s) => s.items.length, 'fresh items', 2),
    ],
  );

  blocTest<CoursesBloc, PagedState<Course, CourseQuery>>(
    'surfaces a failure on the first page',
    build: () {
      when(() => getCourses(any())).thenAnswer(
        (_) async => left(const NetworkFailure()),
      );
      return build();
    },
    act: (bloc) => bloc.add(const PagedStarted<CourseQuery>()),
    verify: (bloc) {
      expect(bloc.state.status, PagedStatus.failure);
      expect(bloc.state.failure, const NetworkFailure());
      expect(bloc.state.hasFullScreenFailure, isTrue);
    },
  );
}
