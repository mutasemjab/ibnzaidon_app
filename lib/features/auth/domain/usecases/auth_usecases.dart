import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/auth/domain/entities/student.dart';
import 'package:ibnzaidon/features/auth/domain/repositories/auth_repository.dart';

final class LoginParams extends Equatable {
  const LoginParams({required this.phone, required this.password});

  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone, password];
}

class LoginUseCase implements UseCase<Student, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Student>> call(LoginParams params) =>
      _repository.login(phone: params.phone, password: params.password);
}

final class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.email,
    this.classId,
  });

  final String name;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? email;
  final int? classId;

  @override
  List<Object?> get props => [
    name,
    phone,
    password,
    passwordConfirmation,
    email,
    classId,
  ];
}

class RegisterUseCase implements UseCase<Student, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Student>> call(RegisterParams params) =>
      _repository.register(
        name: params.name,
        phone: params.phone,
        password: params.password,
        passwordConfirmation: params.passwordConfirmation,
        email: params.email,
        classId: params.classId,
      );
}

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Student?> call() => _repository.restoreSession();
}

class LogoutUseCase implements UseCase<void, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.logout();
}

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.deleteAccount();
}

/// Implemented and injectable, but its UI stays behind
/// `FeatureFlags.siblingSwitch` until the backend lists siblings.
class SwitchSiblingUseCase implements UseCase<Student, int> {
  const SwitchSiblingUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Student>> call(int siblingId) =>
      _repository.switchSibling(siblingId);
}

class ClearLocalSessionUseCase {
  const ClearLocalSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.clearLocalSession();
}
