import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/info_pages/domain/entities/info_page.dart';

abstract interface class InfoPagesRepository {
  Future<Either<Failure, InfoPage>> fetch(String slug);
}
