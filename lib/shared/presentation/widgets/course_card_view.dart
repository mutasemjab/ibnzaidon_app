import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/teacher_avatar_card.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

String courseHeroTag(int courseId) => 'course-thumb-$courseId';
String teacherHeroTag(int teacherId) => 'teacher-avatar-$teacherId';

/// Maps a [Course] entity onto the design-system [CourseCard]. Price and
/// discount go through [PriceView]/[DiscountBadge] so `show_price` applies.
class CourseCardView extends StatelessWidget {
  const CourseCardView({
    required this.course,
    this.variant = CourseCardVariant.vertical,
    this.progress,
    this.enableHero = false,
    this.onTap,
    super.key,
  });

  final Course course;
  final CourseCardVariant variant;

  /// 0..1 when the student is enrolled.
  final double? progress;

  /// Only enable where the course appears once per route (Hero tags must be
  /// unique on a page).
  final bool enableHero;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CourseCard(
      title: course.title,
      thumbnailUrl: course.thumbnail,
      teacherName: course.teacher?.name,
      teacherAvatarUrl: course.teacher?.avatar,
      rating: course.averageRating > 0 ? course.averageRating : null,
      progress: progress,
      variant: variant,
      heroTag: enableHero ? courseHeroTag(course.id) : null,
      priceSlot: progress != null
          ? null
          : PriceView(
              price: course.price,
              oldPrice: course.oldPrice,
              isFree: course.isFree,
            ),
      discountSlot: progress != null || course.discountPercent <= 0
          ? null
          : DiscountBadge(percent: course.discountPercent),
      onTap: onTap ?? () => context.push(AppRoutes.course(course.id)),
    );
  }
}

class TeacherCardView extends StatelessWidget {
  const TeacherCardView({
    required this.teacher,
    this.enableHero = false,
    super.key,
  });

  final Teacher teacher;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    return TeacherAvatarCard(
      name: teacher.name,
      avatarUrl: teacher.avatar,
      specialization: teacher.specialization,
      rating: teacher.averageRating > 0 ? teacher.averageRating : null,
      isVerified: teacher.isVerified,
      heroTag: enableHero ? teacherHeroTag(teacher.id) : null,
      onTap: () => context.push(AppRoutes.teacher(teacher.id)),
    );
  }
}
