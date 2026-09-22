import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/profile/domain/entities/profile.dart';
import 'package:ibnzaidon/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<Profile, NoParams> {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Profile>> call(NoParams params) =>
      _repository.getProfile();
}

class UpdateProfileUseCase implements UseCase<Profile, ProfileUpdate> {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Profile>> call(ProfileUpdate update) =>
      _repository.updateProfile(update);
}

final class ChangePasswordParams {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmation,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmation;
}

/// Password change is a profile update with the password triple.
class ChangePasswordUseCase implements UseCase<Profile, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Profile>> call(ChangePasswordParams params) =>
      _repository.updateProfile(
        ProfileUpdate(
          currentPassword: params.currentPassword,
          newPassword: params.newPassword,
          newPasswordConfirmation: params.confirmation,
        ),
      );
}
