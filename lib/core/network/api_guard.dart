import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/crash_reporter.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/failure_mapper.dart';

/// Thrown when the server answers 2xx but `status:false`.
final class ApiBusinessException implements Exception {
  const ApiBusinessException(this.failure);

  final Failure failure;
}

/// Wraps every repository call: catches transport/parsing errors, maps them
/// to a [Failure], and reports unexpected ones (malformed JSON etc.).
class ApiGuard {
  const ApiGuard(this._crashReporter);

  final CrashReporter _crashReporter;

  Future<Either<Failure, T>> run<T>(Future<T> Function() action) async {
    try {
      return Right<Failure, T>(await action());
    } on DioException catch (error) {
      final failure = mapDioException(error);
      if (failure is UnknownFailure) {
        _crashReporter.recordError(error, error.stackTrace, reason: 'dio');
      }
      return Left<Failure, T>(failure);
    } on ApiBusinessException catch (error) {
      return Left<Failure, T>(error.failure);
    } on Object catch (error, stackTrace) {
      _crashReporter.recordError(error, stackTrace, reason: 'unexpected');
      return Left<Failure, T>(const UnknownFailure());
    }
  }
}
