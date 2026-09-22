import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_card.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';

/// Maps backend icon names (Bootstrap-style `bi-*`) to Material icons.
abstract final class CatalogIcons {
  static const _map = <String, IconData>{
    'stars': Icons.auto_awesome_rounded,
    'star': Icons.star_rounded,
    'book': Icons.menu_book_rounded,
    'journal': Icons.menu_book_rounded,
    'calculator': Icons.calculate_rounded,
    'math': Icons.calculate_rounded,
    'flask': Icons.science_rounded,
    'science': Icons.science_rounded,
    'globe': Icons.public_rounded,
    'translate': Icons.translate_rounded,
    'language': Icons.translate_rounded,
    'laptop': Icons.laptop_rounded,
    'code': Icons.code_rounded,
    'pc': Icons.computer_rounded,
    'music': Icons.music_note_rounded,
    'palette': Icons.palette_rounded,
    'brush': Icons.brush_rounded,
    'trophy': Icons.emoji_events_rounded,
    'mortarboard': Icons.school_rounded,
    'building': Icons.apartment_rounded,
    'people': Icons.groups_rounded,
    'heart': Icons.favorite_rounded,
    'pencil': Icons.edit_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'moon': Icons.nightlight_round,
  };

  static IconData resolve(String? name) {
    final key = (name ?? '').toLowerCase().replaceFirst(
      RegExp(r'^(bi|fa|fas|far)[-\s]+'),
      '',
    );
    for (final entry in _map.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return Icons.category_rounded;
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.onTap,
    this.horizontal = false,
    super.key,
  });

  final Category category;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tint = context.palette.tintFor('${category.id % 6}');
    final leading = category.image != null
        ? AppNetworkImage(
            url: category.image,
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            borderRadius: AppRadii.fieldRadius,
            placeholderIcon: CatalogIcons.resolve(category.icon),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: tint.background,
              borderRadius: AppRadii.fieldRadius,
            ),
            child: SizedBox.square(
              dimension: AppSizes.avatarMd,
              child: Icon(
                CatalogIcons.resolve(category.icon),
                color: tint.foreground,
              ),
            ),
          );
    final label = Text(
      category.name,
      // The vertical variant sits in a fixed-height carousel/grid cell
      // (e.g. the home strip: 128 tall minus card padding), so a 2-line
      // wrap of a long real category name overflowed it. One line there;
      // the horizontal row has unconstrained height, so 2 lines is safe.
      maxLines: horizontal ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      style: context.text.titleSmall,
    );
    return AppCard(
      onTap: onTap,
      semanticLabel: category.name,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: horizontal
          ? Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(child: label),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(height: AppSpacing.sm),
                // Flexible so an extreme case (huge accessibility text
                // scale, an unbreakable long word) clips instead of
                // throwing a render overflow.
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      label,
                      if (category.subcategoriesCount > 0)
                        Text(
                          context.l10n.categorySubcategories(
                            category.subcategoriesCount,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Subject tile tinted by the API's `color_class`.
class SubjectTile extends StatelessWidget {
  const SubjectTile({required this.subject, required this.onTap, super.key});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = context.palette.tintFor(subject.colorClass);
    return AppCard(
      onTap: onTap,
      color: tint.background,
      semanticLabel: subject.name,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(CatalogIcons.resolve(subject.icon), color: tint.foreground),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              subject.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall?.copyWith(color: tint.foreground),
            ),
          ),
          if (subject.isElective)
            Text(
              context.l10n.subjectElective,
              style: context.text.labelSmall?.copyWith(color: tint.foreground),
            ),
        ],
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({required this.trail, super.key});

  final List<String> trail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          for (var i = 0; i < trail.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                child: Icon(Icons.chevron_right_rounded, size: AppSizes.iconMd),
              ),
            Text(
              trail[i],
              style: context.text.labelLarge?.copyWith(
                color: i == trail.length - 1
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
