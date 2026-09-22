import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Avatar-first teacher tile (carousels) with verified badge and rating.
class TeacherAvatarCard extends StatelessWidget {
  const TeacherAvatarCard({
    required this.name,
    this.avatarUrl,
    this.specialization,
    this.rating,
    this.isVerified = false,
    this.heroTag,
    this.onTap,
    super.key,
  });

  final String name;
  final String? avatarUrl;
  final String? specialization;
  final double? rating;
  final bool isVerified;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = AppNetworkImage(
      url: avatarUrl,
      width: AppSizes.avatarLg,
      height: AppSizes.avatarLg,
      circle: true,
      placeholderIcon: Icons.person_rounded,
    );
    return Semantics(
      button: onTap != null,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: SizedBox(
          width: AppSizes.teacherCardWidth,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (heroTag == null)
                      avatar
                    else
                      Hero(tag: heroTag!, child: avatar),
                    if (isVerified)
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            size: AppSizes.iconMd,
                            color: context.colors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // This card sits in a fixed-aspect-ratio grid cell, so the
                // column above (and everything below it) only has as much
                // height as the grid gives it. A verified teacher with a
                // two-line name, a specialization and a rating chip all at
                // once easily exceeds that with real (longer) Arabic names —
                // Flexible lets this block shrink instead of overflowing.
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                      if (specialization != null)
                        Text(
                          specialization!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      if (rating != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        RatingChip(rating: rating!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
