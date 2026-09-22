import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';

/// One class = one action. Blocs depend on use cases, never repositories.
abstract interface class UseCase<Out, Params> {
  Future<Either<Failure, Out>> call(Params params);
}

final class NoParams {
  const NoParams();
}
