import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';

class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApiEnvelope> fetchBanners() =>
      _client.get('banners', optionalAuth: true);

  Future<ApiEnvelope> fetchCategories() =>
      _client.get('categories', optionalAuth: true);

  Future<ApiEnvelope> fetchCategoryDetail(int id) =>
      _client.get('categories/$id', optionalAuth: true);

  Future<ApiEnvelope> fetchSubjectDetail(int id) =>
      _client.get('subjects/$id', optionalAuth: true);
}
