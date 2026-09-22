import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';
import 'package:ibnzaidon/features/home/domain/repositories/home_repository.dart';

class GetHomeUseCase implements UseCase<HomeData, NoParams> {
  const GetHomeUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeData>> call(NoParams params) =>
      _repository.getHome();
}
