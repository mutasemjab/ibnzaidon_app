import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/info_pages/domain/entities/info_page.dart';
import 'package:ibnzaidon/features/info_pages/domain/repositories/info_pages_repository.dart';

class InfoPagesRepositoryImpl implements InfoPagesRepository {
  InfoPagesRepositoryImpl({required ApiClient client, required ApiGuard guard})
    : _client = client,
      _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, InfoPage>> fetch(String slug) => _guard.run(() async {
    final envelope = await _client.get('pages/$slug', optionalAuth: true);
    return InfoPage(
      title: parseString(envelope.dataMap['title']),
      body: parseString(envelope.dataMap['body']),
    );
  });
}
