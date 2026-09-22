import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/core/storage/key_value_store.dart';
import 'package:ibnzaidon/core/storage/secure_storage.dart';
import 'package:ibnzaidon/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ibnzaidon/features/auth/data/models/student_model.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStorage secureStorage,
    required KeyValueStore store,
    required JsonCache cache,
    required ApiGuard guard,
  }) : _remote = remote,
       _secureStorage = secureStorage,
       _store = store,
       _cache = cache,
       _guard = guard;

  static const _studentKey = 'auth.student';

  final AuthRemoteDataSource _remote;
  final SecureStorage _secureStorage;
  final KeyValueStore _store;
  final JsonCache _cache;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, Student>> login({
    required String phone,
    required String password,
  }) => _guard.run(() async {
    final deviceId = await _secureStorage.getOrCreateDeviceId();
    final payload = await _remote.login(
      phone: phone,
      password: password,
      deviceId: deviceId,
    );
    return _persist(payload);
  });

  @override
  Future<Either<Failure, Student>> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  }) => _guard.run(() async {
    final deviceId = await _secureStorage.getOrCreateDeviceId();
    final payload = await _remote.register(
      name: name,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      deviceId: deviceId,
      email: email,
      classId: classId,
    );
    return _persist(payload);
  });

  @override
  Future<Student?> restoreSession() async {
    final token = await _secureStorage.readToken();
    if (token == null || token.isEmpty) return null;
    final result = await _guard.run(_remote.fetchCurrentStudent);
    return result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await clearLocalSession();
          return null;
        }
        return _cachedStudent();
      },
      (student) async {
        await cacheStudent(student);
        return student;
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Local sign-out must always succeed, even when the server call fails.
    await _guard.run(_remote.logout);
    await clearLocalSession();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    final result = await _guard.run(_remote.deleteAccount);
    if (result.isRight()) await clearLocalSession();
    return result;
  }

  @override
  Future<Either<Failure, Student>> switchSibling(int siblingId) =>
      _guard.run(() async => _persist(await _remote.switchSibling(siblingId)));

  @override
  Future<void> clearLocalSession() async {
    await _secureStorage.deleteToken();
    await _store.remove(_studentKey);
    await _cache.clear();
  }

  @override
  Future<void> cacheStudent(Student student) =>
      _store.setJson(_studentKey, StudentModel.fromEntity(student).toJson());

  Future<Student> _persist(AuthPayload payload) async {
    await _secureStorage.writeToken(payload.token);
    await cacheStudent(payload.student);
    return payload.student;
  }

  Student? _cachedStudent() {
    final json = _store.getJson(_studentKey);
    if (json is! Map) return null;
    try {
      return StudentModel.fromJson(Map<String, dynamic>.from(json));
    } on Object {
      return null;
    }
  }
}
