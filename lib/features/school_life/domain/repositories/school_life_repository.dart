import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';

/// Feature-flagged endpoints whose response shape the contract leaves open.
abstract interface class SchoolLifeRepository {
  Future<Either<Failure, List<SchoolRecord>>> getRecords(SchoolRecordKind kind);
  Future<Either<Failure, SchoolRecord>> getAnnouncement(int id);
  Future<Either<Failure, ConductOverview>> getConduct();
  Future<Either<Failure, ConductStatus>> signConduct();
}
