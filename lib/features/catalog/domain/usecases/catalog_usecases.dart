import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/domain/repositories/catalog_repository.dart';

class GetBannersUseCase implements UseCase<List<AppBanner>, NoParams> {
  const GetBannersUseCase(this._repository);

  final CatalogRepository _repository;

  @override
  Future<Either<Failure, List<AppBanner>>> call(NoParams params) =>
      _repository.getBanners();
}

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  const GetCategoriesUseCase(this._repository);

  final CatalogRepository _repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) =>
      _repository.getCategories();
}

class GetCategoryDetailUseCase implements UseCase<CategoryDetail, int> {
  const GetCategoryDetailUseCase(this._repository);

  final CatalogRepository _repository;

  @override
  Future<Either<Failure, CategoryDetail>> call(int id) =>
      _repository.getCategoryDetail(id);
}

class GetSubjectDetailUseCase implements UseCase<SubjectDetail, int> {
  const GetSubjectDetailUseCase(this._repository);

  final CatalogRepository _repository;

  @override
  Future<Either<Failure, SubjectDetail>> call(int id) =>
      _repository.getSubjectDetail(id);
}
