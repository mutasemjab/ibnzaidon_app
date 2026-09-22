import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/shared/data/models/course_model.dart';

abstract final class CatalogModels {
  static Category category(Map<String, dynamic> json) => Category(
    id: parseInt(json['id']),
    name: parseString(json['name'] ?? json['name_ar'] ?? json['name_en']),
    level: parseInt(json['level']),
    icon: tryParseString(json['icon']),
    image: tryParseString(json['image']),
    hasChildren: parseBool(json['has_children']),
    subcategoriesCount: parseInt(json['subcategories_count']),
  );

  static Subject subject(Map<String, dynamic> json) => Subject(
    id: parseInt(json['id']),
    name: parseString(json['name'] ?? json['name_ar'] ?? json['name_en']),
    icon: tryParseString(json['icon']),
    colorClass: tryParseString(json['color_class']),
    isElective: parseBool(json['is_elective']),
    categoryId: tryParseInt(json['category_id']),
  );

  static AppBanner? banner(Map<String, dynamic> json) {
    final image = tryParseString(json['image']);
    if (image == null) return null;
    return AppBanner(
      id: parseInt(json['id']),
      image: image,
      orderIndex: parseInt(json['order_index']),
    );
  }

  static List<Category> categories(Object? raw) => mapList(raw, category);

  static List<AppBanner> banners(Object? raw) {
    final banners = mapList(raw, banner).whereType<AppBanner>().toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return banners;
  }

  static CategoryDetail categoryDetail(Map<String, dynamic> data) {
    final categoryMap = asMap(data['category']);
    if (categoryMap == null) {
      throw const FormatException('category missing');
    }
    return CategoryDetail(
      category: category(categoryMap),
      children: categories(data['children']),
      subjects: mapList(data['subjects'], subject),
    );
  }

  static SubjectDetail subjectDetail(Map<String, dynamic> data) {
    final subjectMap = asMap(data['subject']);
    if (subjectMap == null) {
      throw const FormatException('subject missing');
    }
    return SubjectDetail(
      subject: subject(subjectMap),
      courses: mapList(data['courses'], CourseModel.fromJson),
    );
  }
}
