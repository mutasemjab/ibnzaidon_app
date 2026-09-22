import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/services/haptics.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation with a sliding gradient indicator above the active tab.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final alignment = items.length <= 1
        ? 0.0
        : -1 + 2 * currentIndex / (items.length - 1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        boxShadow: AppShadows.raised(context),
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppMotion.medium,
                curve: AppMotion.emphasizedDecelerate,
                alignment: AlignmentDirectional(alignment, -1),
                child: FractionallySizedBox(
                  widthFactor: 1 / items.length,
                  child: Center(
                    child: Container(
                      width: AppSizes.iconXl - AppSpacing.md,
                      height: AppSizes.indicatorHeight,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppSpacing.xs),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () {
                          Haptics.tap();
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: AppMotion.medium,
              curve: AppMotion.emphasizedDecelerate,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: color,
                size: AppSizes.icon,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
