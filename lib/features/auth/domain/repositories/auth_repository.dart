import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Student>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, Student>> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? email,
    int? classId,
  });

  /// Returns the signed-in student for a stored token, or `null` when there
  /// is no (valid) session. Never fails hard: startup must not depend on
  /// a single endpoint.
  Future<Student?> restoreSession();

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, Student>> switchSibling(int siblingId);

  /// Drops token + user-scoped caches without calling the server.
  Future<void> clearLocalSession();

  Future<void> cacheStudent(Student student);
}
