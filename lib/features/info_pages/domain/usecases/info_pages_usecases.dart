import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/info_pages/domain/entities/info_page.dart';
import 'package:ibnzaidon/features/info_pages/domain/repositories/info_pages_repository.dart';

class GetInfoPageUseCase implements UseCase<InfoPage, String> {
  const GetInfoPageUseCase(this._repository);

  final InfoPagesRepository _repository;

  @override
  Future<Either<Failure, InfoPage>> call(String slug) =>
      _repository.fetch(slug);
}
