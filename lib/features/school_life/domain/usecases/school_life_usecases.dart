import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/domain/repositories/school_life_repository.dart';

class GetSchoolRecordsUseCase
    implements UseCase<List<SchoolRecord>, SchoolRecordKind> {
  const GetSchoolRecordsUseCase(this._repository);

  final SchoolLifeRepository _repository;

  @override
  Future<Either<Failure, List<SchoolRecord>>> call(SchoolRecordKind kind) =>
      _repository.getRecords(kind);
}

class GetAnnouncementUseCase implements UseCase<SchoolRecord, int> {
  const GetAnnouncementUseCase(this._repository);

  final SchoolLifeRepository _repository;

  @override
  Future<Either<Failure, SchoolRecord>> call(int id) =>
      _repository.getAnnouncement(id);
}

class GetConductUseCase implements UseCase<ConductOverview, NoParams> {
  const GetConductUseCase(this._repository);

  final SchoolLifeRepository _repository;

  @override
  Future<Either<Failure, ConductOverview>> call(NoParams params) =>
      _repository.getConduct();
}

class SignConductUseCase implements UseCase<ConductStatus, NoParams> {
  const SignConductUseCase(this._repository);

  final SchoolLifeRepository _repository;

  @override
  Future<Either<Failure, ConductStatus>> call(NoParams params) =>
      _repository.signConduct();
}
