import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:ibnzaidon/features/courses/data/models/course_models.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/repositories/courses_repository.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';
import 'package:ibnzaidon/shared/data/paged_parser.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl({
    required CoursesRemoteDataSource remote,
    required JsonCache cache,
    required ApiGuard guard,
  }) : _remote = remote,
       _cache = cache,
       _guard = guard;

  static const _myCoursesCacheKey = 'my_courses.page1';

  final CoursesRemoteDataSource _remote;
  final JsonCache _cache;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, PagedList<Course>>> getCourses(
    int page,
    CourseQuery query,
  ) => _guard.run(() async {
    final envelope = await _remote.fetchCourses(page, query);
    return pagedFromEnvelope<Course>(envelope, CourseModel.fromJson);
  });

  @override
  Future<Either<Failure, CourseDetail>> getCourseDetail(int id) =>
      _guard.run(() async {
        final envelope = await _remote.fetchCourseDetail(id);
        return CourseModels.courseDetail(envelope.dataMap);
      });

  @override
  Future<Either<Failure, CourseUnits>> getCourseUnits(int id) =>
      _guard.run(() async {
        final envelope = await _remote.fetchCourseUnits(id);
        return CourseModels.courseUnits(envelope.dataMap);
      });

  @override
  Future<Either<Failure, CourseProgress>> getCourseProgress(int id) =>
      _guard.run(() async {
        final envelope = await _remote.fetchCourseProgress(id);
        return CourseModels.courseProgress(envelope.dataMap);
      });

  @override
  Future<Either<Failure, PagedList<Enrollment>>> getMyCourses(int page) {
    if (page > 1) {
      return _guard.run(() async {
        final envelope = await _remote.fetchMyCourses(page);
        return pagedFromEnvelope<Enrollment>(envelope, CourseModels.enrollment);
      });
    }
    return _cache.fetch(
      guard: _guard,
      key: _myCoursesCacheKey,
      remote: () => _remote.fetchMyCourses(1),
      parse: (envelope) =>
          pagedFromEnvelope<Enrollment>(envelope, CourseModels.enrollment),
    );
  }

  @override
  Future<Either<Failure, ActivationResult>> activateCourse(
    int courseId,
    String cardCode,
  ) => _guard.run(() async {
    final envelope = await _remote.activate(courseId, cardCode);
    return CourseModels.activation(envelope.dataMap);
  });

  @override
  Future<Either<Failure, PurchaseVerification>> verifyApplePurchase(
    ApplePurchaseProof proof,
  ) => _guard.run(() async {
    final envelope = await _remote.verifyApplePurchase(proof);
    return CourseModels.purchaseVerification(envelope.dataMap);
  });
}
