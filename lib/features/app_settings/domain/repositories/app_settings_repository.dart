import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/app_settings/domain/entities/app_settings.dart';

abstract interface class AppSettingsRepository {
  Future<Either<Failure, AppSettings>> fetch();

  /// Last value seen from the server. Defaults to hidden until known.
  AppSettings get lastKnown;
}
