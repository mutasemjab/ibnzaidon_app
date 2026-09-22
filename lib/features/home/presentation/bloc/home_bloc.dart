import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';
import 'package:ibnzaidon/features/home/domain/usecases/get_home_use_case.dart';

/// Signed-in home content (`GET home`). Banners and categories have their own
/// blocs so each section can fail independently.
class HomeBloc extends ResourceBloc<HomeData> {
  HomeBloc(this._getHome);

  final GetHomeUseCase _getHome;

  @override
  Future<Either<Failure, HomeData>> load() => _getHome(const NoParams());
}
