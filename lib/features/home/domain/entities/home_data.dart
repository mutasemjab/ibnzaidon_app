import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

class PlatformStats extends Equatable {
  const PlatformStats({
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalCourses = 0,
  });

  final int totalStudents;
  final int totalTeachers;
  final int totalCourses;

  bool get isEmpty =>
      totalStudents == 0 && totalTeachers == 0 && totalCourses == 0;

  @override
  List<Object?> get props => [totalStudents, totalTeachers, totalCourses];
}

class HomeData extends Equatable {
  const HomeData({
    this.categories = const [],
    this.featuredCourses = const [],
    this.trendingCourses = const [],
    this.topTeachers = const [],
    this.stats = const PlatformStats(),
  });

  final List<Category> categories;
  final List<Course> featuredCourses;
  final List<Course> trendingCourses;
  final List<Teacher> topTeachers;
  final PlatformStats stats;

  @override
  List<Object?> get props => [
    categories,
    featuredCourses,
    trendingCourses,
    topTeachers,
    stats,
  ];
}
