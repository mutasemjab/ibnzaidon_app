import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/network/locale_code_provider.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';

/// Locale-scoped JSON cache for the endpoints that must work offline
/// (home, categories, banners, my-courses).
class JsonCache {
  JsonCache(this._store, this._locale);

  static const _prefix = 'cache.';

  final KeyValueStore _store;
  final LocaleCodeProvider _locale;

  String _scoped(String key) => '$_prefix${_locale.languageCode}.$key';

  Future<void> write(String key, Map<String, dynamic> json) =>
      _store.setJson(_scoped(key), json);

  Map<String, dynamic>? read(String key) {
    final json = _store.getJson(_scoped(key));
    return json is Map<String, dynamic> ? json : null;
  }

  Future<void> clear() async {
    final cached = _store.keys.where((key) => key.startsWith(_prefix)).toList();
    for (final key in cached) {
      await _store.remove(key);
    }
  }

  /// Network first; on a [NetworkFailure] falls back to the last good payload.
  Future<Either<Failure, T>> fetch<T>({
    required ApiGuard guard,
    required String key,
    required Future<ApiEnvelope> Function() remote,
    required T Function(ApiEnvelope envelope) parse,
  }) async {
    final result = await guard.run(() async {
      final envelope = await remote();
      final parsed = parse(envelope);
      await write(key, envelope.toJson());
      return parsed;
    });
    return result.fold((failure) {
      if (failure is! NetworkFailure) return Left<Failure, T>(failure);
      final cached = read(key);
      if (cached == null) return Left<Failure, T>(failure);
      try {
        return Right<Failure, T>(parse(ApiEnvelope.fromJson(cached)));
      } on Object {
        return Left<Failure, T>(failure);
      }
    }, Right<Failure, T>.new);
  }
}
