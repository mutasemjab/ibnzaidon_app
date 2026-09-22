import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Cached network image with a designed placeholder for null/failed URLs
/// (never a broken image) and subtle dimming in dark mode.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholderIcon = Icons.school_rounded,
    this.circle = false,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final address = url?.trim();
    final placeholder = ImagePlaceholder(icon: placeholderIcon);
    final image = address == null || address.isEmpty
        ? placeholder
        : Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: address,
                fit: fit,
                fadeInDuration: AppMotion.medium,
                placeholder: (_, _) => const ImagePlaceholder(showIcon: false),
                errorWidget: (_, _, _) => placeholder,
              ),
              Builder(
                builder: (context) {
                  final dimming = context.palette.imageDimming;
                  return dimming == 0
                      ? const SizedBox.shrink()
                      : ColoredBox(
                          color: Colors.black.withValues(alpha: dimming),
                        );
                },
              ),
            ],
          );
    final clipped = circle
        ? ClipOval(child: image)
        : ClipRRect(borderRadius: borderRadius, child: image);
    return SizedBox(width: width, height: height, child: clipped);
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    this.icon = Icons.school_rounded,
    this.showIcon = true,
    super.key,
  });

  final IconData icon;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: showIcon
          ? Center(
              child: Icon(
                icon,
                size: AppSizes.iconLg,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
            )
          : null,
    );
  }
}
