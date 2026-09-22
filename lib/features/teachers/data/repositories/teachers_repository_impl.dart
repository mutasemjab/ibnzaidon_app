import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/teachers/data/datasources/teachers_remote_data_source.dart';
import 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart';
import 'package:ibnzaidon/features/teachers/domain/repositories/teachers_repository.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';
import 'package:ibnzaidon/shared/data/paged_parser.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class TeachersRepositoryImpl implements TeachersRepository {
  const TeachersRepositoryImpl({
    required TeachersRemoteDataSource remote,
    required ApiGuard guard,
  }) : _remote = remote,
       _guard = guard;

  final TeachersRemoteDataSource _remote;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, PagedList<Teacher>>> getTeachers(
    int page,
    TeachersQuery query,
  ) => _guard.run(() async {
    final envelope = await _remote.fetchTeachers(page, query.search);
    return pagedFromEnvelope<Teacher>(envelope, TeacherModel.fromJson);
  });

  @override
  Future<Either<Failure, TeacherDetail>> getTeacherDetail(int id) =>
      _guard.run(() async {
        final data = (await _remote.fetchTeacher(id)).dataMap;
        final teacherJson = asMap(data['teacher']) ?? data;
        return TeacherDetail(
          teacher: TeacherModel.fromJson(teacherJson),
          bio: tryParseString(teacherJson['bio']),
          qualification: tryParseString(teacherJson['qualification']),
          courses: mapList(
            teacherJson['courses'] ?? data['courses'],
            CourseModel.fromJson,
          ),
        );
      });
}
