import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/storage/json_cache.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/catalog/data/models/catalog_models.dart';
import 'package:ibnzaidon/features/home/domain/entities/home_data.dart';
import 'package:ibnzaidon/features/home/domain/repositories/home_repository.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required ApiClient client,
    required JsonCache cache,
    required ApiGuard guard,
  }) : _client = client,
       _cache = cache,
       _guard = guard;

  final ApiClient _client;
  final JsonCache _cache;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, HomeData>> getHome() => _cache.fetch(
    guard: _guard,
    key: 'home',
    remote: () => _client.get('home'),
    parse: _parse,
  );

  /// Each section is parsed independently so a malformed one is empty rather
  /// than breaking the whole page.
  HomeData _parse(ApiEnvelope envelope) {
    final data = envelope.dataMap;
    final stats = asMap(data['stats']) ?? const <String, dynamic>{};
    return HomeData(
      categories: CatalogModels.categories(data['categories']),
      featuredCourses: mapList(data['featured_courses'], CourseModel.fromJson),
      trendingCourses: mapList(data['trending_courses'], CourseModel.fromJson),
      topTeachers: mapList(data['top_teachers'], TeacherModel.fromJson),
      stats: PlatformStats(
        totalStudents: parseInt(stats['total_students']),
        totalTeachers: parseInt(stats['total_teachers']),
        totalCourses: parseInt(stats['total_courses']),
      ),
    );
  }
}
