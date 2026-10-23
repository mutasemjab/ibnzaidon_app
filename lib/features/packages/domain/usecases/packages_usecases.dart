import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/domain/repositories/packages_repository.dart';

class GetPackagesUseCase implements UseCase<List<Package>, NoParams> {
  const GetPackagesUseCase(this._repository);

  final PackagesRepository _repository;

  @override
  Future<Either<Failure, List<Package>>> call(NoParams params) =>
      _repository.getPackages();
}

class GetPackageDetailUseCase implements UseCase<PackageDetail, int> {
  const GetPackageDetailUseCase(this._repository);

  final PackagesRepository _repository;

  @override
  Future<Either<Failure, PackageDetail>> call(int packageId) =>
      _repository.getPackageDetail(packageId);
}

final class ActivatePackageParams extends Equatable {
  const ActivatePackageParams({
    required this.packageId,
    required this.cardCode,
    required this.courseIds,
  });

  final int packageId;
  final String cardCode;
  final List<int> courseIds;

  @override
  List<Object?> get props => [packageId, cardCode, courseIds];
}

class ActivatePackageUseCase
    implements UseCase<PackageActivationResult, ActivatePackageParams> {
  const ActivatePackageUseCase(this._repository);

  final PackagesRepository _repository;

  @override
  Future<Either<Failure, PackageActivationResult>> call(
    ActivatePackageParams params,
  ) => _repository.activate(
    packageId: params.packageId,
    cardCode: params.cardCode,
    courseIds: params.courseIds,
  );
}
