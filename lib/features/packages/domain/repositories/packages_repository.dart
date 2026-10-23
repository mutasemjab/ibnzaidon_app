import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';

abstract interface class PackagesRepository {
  Future<Either<Failure, List<Package>>> getPackages();

  Future<Either<Failure, PackageDetail>> getPackageDetail(int id);

  Future<Either<Failure, PackageActivationResult>> activate({
    required int packageId,
    required String cardCode,
    required List<int> courseIds,
  });
}
