import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Pill-style tab bar with an animated sliding indicator.
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({required this.labels, this.controller, super.key});

  final List<String> labels;
  final TabController? controller;

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppSizes.touchTarget + AppSpacing.md);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: AppRadii.pillRadius,
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsetsDirectional.all(AppSpacing.xs),
          indicator: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: AppRadii.pillRadius,
            boxShadow: AppShadows.soft(context),
          ),
          labelColor: scheme.primary,
          unselectedLabelColor: scheme.onSurfaceVariant,
          labelStyle: context.text.labelLarge,
          onTap: (_) => Haptics.tap(),
          tabs: [
            for (final label in labels)
              Tab(text: label, height: AppSizes.touchTarget - AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

/// Segmented control for non-page choices (library kinds, grid/list, ...).
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final keys = segments.keys.toList();
    final index = keys.indexOf(selected).clamp(0, keys.length - 1);
    final alignment = keys.length <= 1
        ? 0.0
        : -1 + 2 * index / (keys.length - 1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadii.pillRadius,
      ),
      child: SizedBox(
        height: AppSizes.touchTarget,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: AppMotion.medium,
              curve: AppMotion.emphasizedDecelerate,
              alignment: AlignmentDirectional(alignment, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / keys.length,
                heightFactor: 1,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: AppRadii.pillRadius,
                      boxShadow: AppShadows.soft(context),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final key in keys)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: key == selected,
                      child: InkWell(
                        borderRadius: AppRadii.pillRadius,
                        onTap: () {
                          Haptics.tap();
                          onChanged(key);
                        },
                        child: Center(
                          child: Text(
                            segments[key]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge?.copyWith(
                              color: key == selected
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
