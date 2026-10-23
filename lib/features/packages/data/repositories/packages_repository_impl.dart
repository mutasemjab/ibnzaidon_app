import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:ibnzaidon/features/packages/data/models/package_model.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/domain/repositories/packages_repository.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

class PackagesRepositoryImpl implements PackagesRepository {
  PackagesRepositoryImpl({
    required PackagesRemoteDataSource remote,
    required ApiGuard guard,
  }) : _remote = remote,
       _guard = guard;

  final PackagesRemoteDataSource _remote;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, List<Package>>> getPackages() => _guard.run(() async {
    final envelope = await _remote.fetchPackages();
    return mapList(envelope.data, PackageModel.fromJson);
  });

  @override
  Future<Either<Failure, PackageDetail>> getPackageDetail(int id) =>
      _guard.run(() async {
        final data = (await _remote.fetchPackageDetail(id)).dataMap;
        return PackageDetail(
          package: PackageModel.fromJson(data),
          courses: mapList(data['courses'], CourseModel.fromJson),
        );
      });

  @override
  Future<Either<Failure, PackageActivationResult>> activate({
    required int packageId,
    required String cardCode,
    required List<int> courseIds,
  }) => _guard.run(() async {
    final data = (await _remote.activate(
      packageId,
      cardCode,
      courseIds,
    )).dataMap;
    return PackageActivationResult(
      packageId: parseInt(data['package_id']),
      courseIds: asList(
        data['course_ids'],
      ).map((e) => tryParseInt(e) ?? 0).toList(),
    );
  });
}
