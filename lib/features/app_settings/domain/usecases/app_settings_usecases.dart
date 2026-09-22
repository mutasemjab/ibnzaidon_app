import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/app_settings/domain/entities/app_settings.dart';
import 'package:ibnzaidon/features/app_settings/domain/repositories/app_settings_repository.dart';

class GetAppSettingsUseCase implements UseCase<AppSettings, NoParams> {
  const GetAppSettingsUseCase(this._repository);

  final AppSettingsRepository _repository;

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) =>
      _repository.fetch();
}

class ReadLastKnownAppSettingsUseCase {
  const ReadLastKnownAppSettingsUseCase(this._repository);

  final AppSettingsRepository _repository;

  AppSettings call() => _repository.lastKnown;
}
