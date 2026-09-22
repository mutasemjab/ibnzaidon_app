import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:ibnzaidon/features/catalog/data/models/catalog_models.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl({
    required CatalogRemoteDataSource remote,
    required JsonCache cache,
    required ApiGuard guard,
  }) : _remote = remote,
       _cache = cache,
       _guard = guard;

  final CatalogRemoteDataSource _remote;
  final JsonCache _cache;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, List<AppBanner>>> getBanners() => _cache.fetch(
    guard: _guard,
    key: 'banners',
    remote: _remote.fetchBanners,
    parse: (envelope) => CatalogModels.banners(envelope.data),
  );

  @override
  Future<Either<Failure, List<Category>>> getCategories() => _cache.fetch(
    guard: _guard,
    key: 'categories',
    remote: _remote.fetchCategories,
    parse: (envelope) => CatalogModels.categories(envelope.data),
  );

  @override
  Future<Either<Failure, CategoryDetail>> getCategoryDetail(int id) =>
      _guard.run(() async {
        final envelope = await _remote.fetchCategoryDetail(id);
        return CatalogModels.categoryDetail(envelope.dataMap);
      });

  @override
  Future<Either<Failure, SubjectDetail>> getSubjectDetail(int id) =>
      _guard.run(() async {
        final envelope = await _remote.fetchSubjectDetail(id);
        return CatalogModels.subjectDetail(envelope.dataMap);
      });
}
