import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// State = "prices may be shown". Backed by the `app-settings` `show_price`
/// flag (App Store compliance) — `AppSettingsCubit` extends this.
class PriceVisibilityCubit extends Cubit<bool> {
  PriceVisibilityCubit({bool initiallyVisible = false})
    : super(initiallyVisible);
}

/// Hides [child] entirely when prices are disabled. Every price, old price,
/// discount badge and buy button goes through this gate.
class PriceGate extends StatelessWidget {
  const PriceGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final visible = context.select<PriceVisibilityCubit, bool>(
      (cubit) => cubit.state,
    );
    return visible ? child : const SizedBox.shrink();
  }
}

/// The single price widget: "Free" chip, price, and struck-through old price.
class PriceView extends StatelessWidget {
  const PriceView({
    required this.price,
    this.oldPrice,
    this.isFree = false,
    this.large = false,
    super.key,
  });

  final double price;
  final double? oldPrice;
  final bool isFree;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return PriceGate(
      child: isFree || price <= 0
          ? _FreeChip(large: large)
          : _PriceText(price: price, oldPrice: oldPrice, large: large),
    );
  }
}

class _FreeChip extends StatelessWidget {
  const _FreeChip({required this.large});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.successContainer,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          context.l10n.commonFree,
          style: (large ? context.text.titleMedium : context.text.labelMedium)
              ?.copyWith(color: palette.onSuccessContainer),
        ),
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText({
    required this.price,
    required this.oldPrice,
    required this.large,
  });

  final double price;
  final double? oldPrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final language = context.languageCode;
    final hasOld = oldPrice != null && oldPrice! > price;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        Text(
          AppFormatters.currency(price, language),
          style: (large ? context.text.titleLarge : context.text.titleSmall)
              ?.copyWith(color: context.colors.primary),
        ),
        if (hasOld)
          Text(
            AppFormatters.currency(oldPrice!, language),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.outline,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

/// Amber "-20%" ribbon. Gated like every other price surface.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();
    return PriceGate(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.warning,
          borderRadius: AppRadii.chipRadius,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Text(
            '-$percent%',
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
