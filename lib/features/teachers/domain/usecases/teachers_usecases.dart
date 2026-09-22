import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/teachers/domain/entities/teacher_detail.dart';
import 'package:ibnzaidon/features/teachers/domain/repositories/teachers_repository.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

final class TeachersPageParams extends Equatable {
  const TeachersPageParams({required this.page, required this.query});

  final int page;
  final TeachersQuery query;

  @override
  List<Object?> get props => [page, query];
}

class GetTeachersUseCase
    implements UseCase<PagedList<Teacher>, TeachersPageParams> {
  const GetTeachersUseCase(this._repository);

  final TeachersRepository _repository;

  @override
  Future<Either<Failure, PagedList<Teacher>>> call(TeachersPageParams params) =>
      _repository.getTeachers(params.page, params.query);
}

class GetTeacherDetailUseCase implements UseCase<TeacherDetail, int> {
  const GetTeacherDetailUseCase(this._repository);

  final TeachersRepository _repository;

  @override
  Future<Either<Failure, TeacherDetail>> call(int id) =>
      _repository.getTeacherDetail(id);
}
