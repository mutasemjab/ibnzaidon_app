import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/network/failure_mapper.dart';
import 'package:ibnzaidon/core/network/interceptors/auth_interceptor.dart';
import 'package:ibnzaidon/core/network/interceptors/unauthorized_interceptor.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fakes.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status, {this.body = '{"status":false,"message":"x"}'});

  final int status;
  final String body;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('mapDioException', () {
    DioException badResponse(int status, [Object? data]) => DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: status,
        data: data,
      ),
    );

    test('maps statuses to typed failures', () {
      expect(mapDioException(badResponse(401)), isA<UnauthorizedFailure>());
      expect(
        mapDioException(badResponse(403, {'message': 'activate first'})),
        const ForbiddenFailure(message: 'activate first'),
      );
      expect(mapDioException(badResponse(404)), isA<NotFoundFailure>());
      expect(mapDioException(badResponse(500)), isA<ServerFailure>());
    });

    test('422 exposes field errors', () {
      final failure = mapDioException(
        badResponse(422, {
          'message': 'invalid',
          'errors': {
            'phone': ['taken'],
          },
        }),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).firstErrorFor('phone'), 'taken');
    });

    test('timeouts and connection errors are NetworkFailure', () {
      expect(
        mapDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
        const NetworkFailure(isTimeout: true),
      );
      expect(
        mapDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        const NetworkFailure(),
      );
    });
  });

  group('ApiGuard', () {
    const guard = ApiGuard(NoopCrashReporter());

    test('malformed JSON becomes UnknownFailure, never a crash', () async {
      final result = await guard.run<int>(
        () async => ApiEnvelope.fromJson('not a map').status ? 1 : 0,
      );
      expect(result, const Left<Failure, int>(UnknownFailure()));
    });
  });

  group('401 handling', () {
    late _MockSecureStorage plugin;
    late SecureStorage storage;
    late SessionExpiryNotifier notifier;
    late int expiries;

    Dio buildDio(_StatusAdapter adapter) {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
        ..httpClientAdapter = adapter;
      dio.interceptors.addAll([
        AuthInterceptor(storage, const FixedLocale('en')),
        UnauthorizedInterceptor(storage, notifier),
      ]);
      return dio;
    }

    setUp(() {
      plugin = _MockSecureStorage();
      when(() => plugin.read(key: 'auth_token')).thenAnswer((_) async => 'tkn');
      when(() => plugin.delete(key: 'auth_token')).thenAnswer((_) async {});
      storage = SecureStorage(plugin);
      notifier = SessionExpiryNotifier();
      expiries = 0;
      notifier.stream.listen((_) => expiries++);
    });

    test('adds bearer, language and accept headers', () async {
      final adapter = _StatusAdapter(200, body: '{"status":true}');
      await buildDio(adapter).get<Object?>('home');
      final headers = adapter.lastRequest!.headers;
      expect(headers['Authorization'], 'Bearer tkn');
      expect(headers['Accept-Language'], 'en');
      expect(headers['Accept'], 'application/json');
    });

    test('a 401 clears the token and notifies once', () async {
      final dio = buildDio(_StatusAdapter(401));
      await expectLater(
        dio.get<Object?>('profile'),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      verify(() => plugin.delete(key: 'auth_token')).called(1);
      expect(expiries, 1);
    });

    test('a 401 on login/register does not expire the session', () async {
      final dio = buildDio(_StatusAdapter(401));
      await expectLater(
        dio.post<Object?>(
          'auth/login',
          options: Options(extra: {skipSessionExpiryKey: true}),
        ),
        throwsA(isA<DioException>()),
      );
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => plugin.delete(key: 'auth_token'));
      expect(expiries, 0);
    });
  });

  group('JsonCache.fetch (offline fallback)', () {
    final cache = JsonCache(InMemoryKeyValueStore(), const FixedLocale());
    const guard = ApiGuard(NoopCrashReporter());

    ApiEnvelope envelope(int value) =>
        ApiEnvelope(status: true, data: {'value': value});
    int parse(ApiEnvelope e) => e.dataMap['value'] as int;

    test('returns fresh data and stores it', () async {
      final result = await cache.fetch<int>(
        guard: guard,
        key: 'k',
        remote: () async => envelope(1),
        parse: parse,
      );
      expect(result, const Right<Failure, int>(1));
    });

    test('serves the cached payload on a network failure', () async {
      final result = await cache.fetch<int>(
        guard: guard,
        key: 'k',
        remote: () async => throw DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
        parse: parse,
      );
      expect(result, const Right<Failure, int>(1));
    });

    test('does not mask non-network failures with stale data', () async {
      final result = await cache.fetch<int>(
        guard: guard,
        key: 'k',
        remote: () async => throw DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: 500,
          ),
        ),
        parse: parse,
      );
      expect(result.isLeft(), isTrue);
    });
  });
}
