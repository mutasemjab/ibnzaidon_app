import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';

class PackagesRemoteDataSource {
  const PackagesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApiEnvelope> fetchPackages() =>
      _client.get('packages', optionalAuth: true);

  Future<ApiEnvelope> fetchPackageDetail(int id) =>
      _client.get('packages/$id', optionalAuth: true);

  Future<ApiEnvelope> activate(
    int packageId,
    String cardCode,
    List<int> courseIds,
  ) => _client.post(
    'packages/$packageId/activate',
    body: {'card_code': cardCode, 'course_ids': courseIds},
  );
}
