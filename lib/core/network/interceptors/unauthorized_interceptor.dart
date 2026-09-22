import 'package:dio/dio.dart';
import 'package:ibnzaidon/core/network/session_expiry_notifier.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';

/// Request `extra` flag: a 401 on this request is a normal business answer
/// (wrong credentials, guest browsing) and must not expire the session.
const skipSessionExpiryKey = 'skipSessionExpiry';

/// On a 401 anywhere except login/register (and optional-auth reads) the
/// token is dropped and the app is told the session expired.
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor(this._storage, this._notifier);

  final SecureStorage _storage;
  final SessionExpiryNotifier _notifier;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final skip = err.requestOptions.extra[skipSessionExpiryKey] == true;
    final hadToken = err.requestOptions.headers.containsKey('Authorization');
    if (err.response?.statusCode == 401 && !skip && hadToken) {
      await _storage.deleteToken();
      _notifier.notifyExpired();
    }
    handler.next(err);
  }
}
