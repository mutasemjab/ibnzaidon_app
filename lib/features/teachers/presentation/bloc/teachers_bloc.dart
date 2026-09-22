import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart';
import 'package:ibnzaidon/features/teachers/domain/usecases/teachers_usecases.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

export 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart'
    show TeachersQuery;

class TeachersBloc extends PagedBloc<Teacher, TeachersQuery> {
  TeachersBloc(this._getTeachers) : super(initialQuery: const TeachersQuery());

  final GetTeachersUseCase _getTeachers;

  @override
  Future<Either<Failure, PagedList<Teacher>>> fetchPage(
    int page,
    TeachersQuery query,
  ) => _getTeachers(TeachersPageParams(page: page, query: query));
}

class TeacherDetailBloc extends ResourceBloc<TeacherDetail> {
  TeacherDetailBloc(this._getTeacher, {required this.teacherId});

  final GetTeacherDetailUseCase _getTeacher;
  final int teacherId;

  @override
  Future<Either<Failure, TeacherDetail>> load() => _getTeacher(teacherId);
}
