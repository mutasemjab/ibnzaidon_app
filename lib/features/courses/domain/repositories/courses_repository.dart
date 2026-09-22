import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

abstract interface class CoursesRepository {
  Future<Either<Failure, PagedList<Course>>> getCourses(
    int page,
    CourseQuery query,
  );
  Future<Either<Failure, CourseDetail>> getCourseDetail(int id);
  Future<Either<Failure, CourseUnits>> getCourseUnits(int id);
  Future<Either<Failure, CourseProgress>> getCourseProgress(int id);
  Future<Either<Failure, PagedList<Enrollment>>> getMyCourses(int page);
  Future<Either<Failure, ActivationResult>> activateCourse(
    int courseId,
    String cardCode,
  );
  Future<Either<Failure, PurchaseVerification>> verifyApplePurchase(
    ApplePurchaseProof proof,
  );
}
