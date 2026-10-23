import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/features/packages/domain/entities/package.dart';

String packageHeroTag(int packageId) => 'package-thumb-$packageId';

/// Maps a [Package] entity onto the design-system [CourseCard] — same visual
/// language as a course tile, just fed bundle fields instead.
class PackageCardView extends StatelessWidget {
  const PackageCardView({
    required this.package,
    this.variant = CourseCardVariant.vertical,
    this.enableHero = false,
    super.key,
  });

  final Package package;
  final CourseCardVariant variant;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    return CourseCard(
      title: package.title,
      thumbnailUrl: package.image,
      subtitle: context.l10n.commonCoursesCount(package.coursesCount),
      variant: variant,
      heroTag: enableHero ? packageHeroTag(package.id) : null,
      priceSlot: PriceView(price: package.price, oldPrice: package.oldPrice),
      discountSlot: package.discountPercent <= 0
          ? null
          : DiscountBadge(percent: package.discountPercent),
      onTap: () => context.push(AppRoutes.package(package.id)),
    );
  }
}
