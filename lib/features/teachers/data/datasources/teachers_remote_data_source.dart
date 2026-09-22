import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';

class TeachersRemoteDataSource {
  const TeachersRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApiEnvelope> fetchTeachers(int page, String search) =>
      _client.get('teachers', query: {'page': page, 'search': search.trim()});

  Future<ApiEnvelope> fetchTeacher(int id) =>
      _client.get('teachers/$id', optionalAuth: true);
}
