import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeData>> getHome();
}
