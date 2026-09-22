import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

abstract interface class TeachersRepository {
  Future<Either<Failure, PagedList<Teacher>>> getTeachers(
    int page,
    TeachersQuery query,
  );
  Future<Either<Failure, TeacherDetail>> getTeacherDetail(int id);
}
