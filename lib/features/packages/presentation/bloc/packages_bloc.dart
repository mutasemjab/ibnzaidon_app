import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';
import 'package:ibnzaidon/features/packages/domain/usecases/packages_usecases.dart';

class PackagesBloc extends ResourceBloc<List<Package>> {
  PackagesBloc(this._getPackages);

  final GetPackagesUseCase _getPackages;

  @override
  Future<Either<Failure, List<Package>>> load() =>
      _getPackages(const NoParams());
}
