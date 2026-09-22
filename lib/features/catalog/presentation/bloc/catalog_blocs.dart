import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/domain/usecases/catalog_usecases.dart';

class BannersBloc extends ResourceBloc<List<AppBanner>> {
  BannersBloc(this._getBanners);

  final GetBannersUseCase _getBanners;

  @override
  Future<Either<Failure, List<AppBanner>>> load() =>
      _getBanners(const NoParams());
}

class CategoriesBloc extends ResourceBloc<List<Category>> {
  CategoriesBloc(this._getCategories);

  final GetCategoriesUseCase _getCategories;

  @override
  Future<Either<Failure, List<Category>>> load() =>
      _getCategories(const NoParams());
}

class CategoryDetailBloc extends ResourceBloc<CategoryDetail> {
  CategoryDetailBloc(this._getCategoryDetail, {required this.categoryId});

  final GetCategoryDetailUseCase _getCategoryDetail;
  final int categoryId;

  @override
  Future<Either<Failure, CategoryDetail>> load() =>
      _getCategoryDetail(categoryId);
}

class SubjectDetailBloc extends ResourceBloc<SubjectDetail> {
  SubjectDetailBloc(this._getSubjectDetail, {required this.subjectId});

  final GetSubjectDetailUseCase _getSubjectDetail;
  final int subjectId;

  @override
  Future<Either<Failure, SubjectDetail>> load() => _getSubjectDetail(subjectId);
}
