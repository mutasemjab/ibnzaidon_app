import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';

abstract interface class CatalogRepository {
  Future<Either<Failure, List<AppBanner>>> getBanners();
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, CategoryDetail>> getCategoryDetail(int id);
  Future<Either<Failure, SubjectDetail>> getSubjectDetail(int id);
}
