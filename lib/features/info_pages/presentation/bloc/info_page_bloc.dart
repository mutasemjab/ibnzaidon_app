import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/info_pages/domain/entities/info_page.dart';
import 'package:ibnzaidon/features/info_pages/domain/usecases/info_pages_usecases.dart';

/// One bloc class reused for all four static pages, parameterized by slug.
class InfoPageBloc extends ResourceBloc<InfoPage> {
  InfoPageBloc(this._getInfoPage, {required this.slug});

  final GetInfoPageUseCase _getInfoPage;
  final String slug;

  @override
  Future<Either<Failure, InfoPage>> load() => _getInfoPage(slug);
}
