import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class CoursesBloc extends PagedBloc<Course, CourseQuery> {
  CoursesBloc(this._getCourses, {super.initialQuery = const CourseQuery()});

  final GetCoursesUseCase _getCourses;

  @override
  Future<Either<Failure, PagedList<Course>>> fetchPage(
    int page,
    CourseQuery query,
  ) => _getCourses(CoursesPageParams(page: page, query: query));
}

class MyCoursesBloc extends PagedBloc<Enrollment, NoQuery> {
  MyCoursesBloc(this._getMyCourses) : super(initialQuery: const NoQuery());

  final GetMyCoursesUseCase _getMyCourses;

  @override
  Future<Either<Failure, PagedList<Enrollment>>> fetchPage(
    int page,
    NoQuery query,
  ) => _getMyCourses(page);
}
