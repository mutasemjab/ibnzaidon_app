import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';

final class PackageModel extends Package {
  const PackageModel({
    required super.id,
    required super.title,
    required super.pickCount,
    super.description,
    super.image,
    super.price,
    super.oldPrice,
    super.discountPercent,
    super.isFeatured,
    super.coursesCount,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final price = parseDouble(json['price']);
    final oldPrice = tryParseDouble(json['old_price']);
    return PackageModel(
      id: parseInt(json['id']),
      title: parseString(json['title'] ?? json['title_ar'] ?? json['title_en']),
      pickCount: parseInt(json['pick_count']),
      description: tryParseString(json['description']),
      image: tryParseString(json['image']),
      price: price,
      oldPrice: oldPrice,
      discountPercent: _discount(json['discount'], price, oldPrice),
      isFeatured: parseBool(json['is_featured']),
      coursesCount: parseInt(json['courses_count']),
    );
  }

  /// `discount` may be a percent or missing; derive it from the old price
  /// when the backend omits it (same rule as `CourseModel`).
  static int _discount(Object? raw, double price, double? oldPrice) {
    final given = tryParseDouble(raw);
    if (given != null && given > 0) return given.round().clamp(0, 100);
    if (oldPrice != null && oldPrice > price && oldPrice > 0) {
      return (((oldPrice - price) / oldPrice) * 100).round();
    }
    return 0;
  }
}
