import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.level = 0,
    this.icon,
    this.image,
    this.hasChildren = false,
    this.subcategoriesCount = 0,
  });

  final int id;
  final String name;
  final int level;
  final String? icon;
  final String? image;
  final bool hasChildren;
  final int subcategoriesCount;

  @override
  List<Object?> get props => [
    id,
    name,
    level,
    icon,
    image,
    hasChildren,
    subcategoriesCount,
  ];
}

class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.name,
    this.icon,
    this.colorClass,
    this.isElective = false,
    this.categoryId,
  });

  final int id;
  final String name;
  final String? icon;
  final String? colorClass;
  final bool isElective;
  final int? categoryId;

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    colorClass,
    isElective,
    categoryId,
  ];
}

class CategoryDetail extends Equatable {
  const CategoryDetail({
    required this.category,
    required this.children,
    required this.subjects,
  });

  final Category category;
  final List<Category> children;
  final List<Subject> subjects;

  @override
  List<Object?> get props => [category, children, subjects];
}

class SubjectDetail extends Equatable {
  const SubjectDetail({required this.subject, required this.courses});

  final Subject subject;
  final List<Course> courses;

  @override
  List<Object?> get props => [subject, courses];
}

class AppBanner extends Equatable {
  const AppBanner({required this.id, required this.image, this.orderIndex = 0});

  final int id;
  final String image;
  final int orderIndex;

  @override
  List<Object?> get props => [id, image, orderIndex];
}
