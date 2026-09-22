import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/repositories/courses_repository.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

final class CoursesPageParams extends Equatable {
  const CoursesPageParams({required this.page, required this.query});

  final int page;
  final CourseQuery query;

  @override
  List<Object?> get props => [page, query];
}

class GetCoursesUseCase
    implements UseCase<PagedList<Course>, CoursesPageParams> {
  const GetCoursesUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, PagedList<Course>>> call(CoursesPageParams params) =>
      _repository.getCourses(params.page, params.query);
}

class GetCourseDetailUseCase implements UseCase<CourseDetail, int> {
  const GetCourseDetailUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, CourseDetail>> call(int courseId) =>
      _repository.getCourseDetail(courseId);
}

class GetCourseUnitsUseCase implements UseCase<CourseUnits, int> {
  const GetCourseUnitsUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, CourseUnits>> call(int courseId) =>
      _repository.getCourseUnits(courseId);
}

class GetCourseProgressUseCase implements UseCase<CourseProgress, int> {
  const GetCourseProgressUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, CourseProgress>> call(int courseId) =>
      _repository.getCourseProgress(courseId);
}

class GetMyCoursesUseCase implements UseCase<PagedList<Enrollment>, int> {
  const GetMyCoursesUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, PagedList<Enrollment>>> call(int page) =>
      _repository.getMyCourses(page);
}

final class ActivateCourseParams extends Equatable {
  const ActivateCourseParams({required this.courseId, required this.cardCode});

  final int courseId;
  final String cardCode;

  @override
  List<Object?> get props => [courseId, cardCode];
}

class ActivateCourseUseCase
    implements UseCase<ActivationResult, ActivateCourseParams> {
  const ActivateCourseUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, ActivationResult>> call(ActivateCourseParams params) =>
      _repository.activateCourse(params.courseId, params.cardCode);
}

class VerifyApplePurchaseUseCase
    implements UseCase<PurchaseVerification, ApplePurchaseProof> {
  const VerifyApplePurchaseUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Either<Failure, PurchaseVerification>> call(
    ApplePurchaseProof proof,
  ) => _repository.verifyApplePurchase(proof);
}
