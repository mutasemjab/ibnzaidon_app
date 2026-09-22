import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/app_settings/domain/entities/app_settings.dart';
import 'package:ibnzaidon/features/app_settings/domain/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({
    required ApiClient client,
    required KeyValueStore store,
    required ApiGuard guard,
  }) : _client = client,
       _store = store,
       _guard = guard;

  static const _showPriceKey = 'app_settings.show_price';

  final ApiClient _client;
  final KeyValueStore _store;
  final ApiGuard _guard;

  @override
  AppSettings get lastKnown =>
      AppSettings(showPrice: _store.getBool(_showPriceKey) ?? false);

  @override
  Future<Either<Failure, AppSettings>> fetch() => _guard.run(() async {
    final envelope = await _client.get('app-settings', optionalAuth: true);
    final showPrice = parseBool(envelope.dataMap['show_price']);
    await _store.setBool(_showPriceKey, value: showPrice);
    return AppSettings(showPrice: showPrice);
  });
}
