import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Token + device id only. Nothing else sensitive lives anywhere else.
class SecureStorage {
  SecureStorage(this._storage, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const _tokenKey = 'auth_token';
  static const _deviceIdKey = 'device_id';

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  /// Generated once (UUID v4, 36 chars) and never regenerated.
  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = _uuid.v4();
    await _storage.write(key: _deviceIdKey, value: created);
    return created;
  }
}
