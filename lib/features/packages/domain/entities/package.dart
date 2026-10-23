import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

/// Bundle card as returned by `GET packages` / `GET packages/{id}`.
class Package extends Equatable {
  const Package({
    required this.id,
    required this.title,
    required this.pickCount,
    this.description,
    this.image,
    this.price = 0,
    this.oldPrice,
    this.discountPercent = 0,
    this.isFeatured = false,
    this.coursesCount = 0,
  });

  final int id;
  final String title;
  final String? description;
  final String? image;

  /// Exactly this many courses must be picked from [PackageDetail.courses]
  /// to activate the bundle.
  final int pickCount;
  final double price;
  final double? oldPrice;
  final int discountPercent;
  final bool isFeatured;
  final int coursesCount;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    image,
    pickCount,
    price,
    oldPrice,
    discountPercent,
    isFeatured,
    coursesCount,
  ];
}

/// [package] plus the pool of courses a student can pick from.
class PackageDetail extends Equatable {
  const PackageDetail({required this.package, required this.courses});

  final Package package;
  final List<Course> courses;

  @override
  List<Object?> get props => [package, courses];
}

class PackageActivationResult extends Equatable {
  const PackageActivationResult({
    required this.packageId,
    required this.courseIds,
  });

  final int packageId;
  final List<int> courseIds;

  @override
  List<Object?> get props => [packageId, courseIds];
}
