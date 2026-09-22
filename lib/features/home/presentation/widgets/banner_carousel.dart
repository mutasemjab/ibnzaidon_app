import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/bloc/resource_bloc.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_network_image.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/catalog/domain/entities/catalog_entities.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Auto-playing hero slider with parallax and a morphing indicator. The
/// section hides itself when banners fail or are empty — it never breaks Home.
class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersBloc, ResourceState<List<AppBanner>>>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SkeletonShimmer(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: SkeletonBox(
                height: AppSizes.bannerHeight,
                radius: AppRadii.card,
              ),
            ),
          );
        }
        final banners = state.data ?? const <AppBanner>[];
        if (banners.isEmpty) return const SizedBox.shrink();
        return _Slider(banners: banners);
      },
    );
  }
}

class _Slider extends StatefulWidget {
  const _Slider({required this.banners});

  final List<AppBanner> banners;

  @override
  State<_Slider> createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  static const _autoPlayInterval = Duration(seconds: 5);
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _page = _controller.page ?? 0),
    );
    _timer = Timer.periodic(_autoPlayInterval, (_) => _advance());
  }

  void _advance() {
    if (!_controller.hasClients || widget.banners.length < 2) return;
    final next = ((_controller.page ?? 0).round() + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: AppMotion.slow,
      curve: AppMotion.emphasizedDecelerate,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.reduceMotion;
    return Column(
      children: [
        SizedBox(
          height: AppSizes.bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final offset = (index - _page).clamp(-1.0, 1.0);
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                child: ClipRRect(
                  borderRadius: AppRadii.cardRadius,
                  child: Transform.translate(
                    offset: Offset(reduceMotion ? 0 : offset * 24, 0),
                    child: Transform.scale(
                      scale: 1.12,
                      child: AppNetworkImage(url: widget.banners[index].image),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          SmoothPageIndicator(
            controller: _controller,
            count: widget.banners.length,
            effect: ExpandingDotsEffect(
              activeDotColor: context.colors.primary,
              dotColor: context.colors.outlineVariant,
              dotHeight: AppSpacing.sm,
              dotWidth: AppSpacing.sm,
            ),
          ),
        ],
      ],
    );
  }
}
