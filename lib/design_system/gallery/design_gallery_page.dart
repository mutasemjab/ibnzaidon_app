import 'package:flutter/material.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/app_bottom_nav.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/app_tabs.dart';
import 'package:ibnzaidon/design_system/components/app_text_field.dart';
import 'package:ibnzaidon/design_system/components/chips.dart';
import 'package:ibnzaidon/design_system/components/course_card.dart';
import 'package:ibnzaidon/design_system/components/exam_timer.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/price_view.dart';
import 'package:ibnzaidon/design_system/components/progress_ring.dart';
import 'package:ibnzaidon/design_system/components/score_gauge.dart';
import 'package:ibnzaidon/design_system/components/section_header.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/components/teacher_avatar_card.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';

/// Hidden page (dev flavor / long-press on the version) showing every
/// design-system component in every state.
class DesignGalleryPage extends StatelessWidget {
  const DesignGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.galleryTitle)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.lg,
          ),
          children: [
            SectionHeader(title: l10n.galleryButtons, padding: EdgeInsets.zero),
            const _ButtonsSection(),
            SectionHeader(title: l10n.galleryInputs, padding: EdgeInsets.zero),
            const _InputsSection(),
            SectionHeader(title: l10n.galleryCards, padding: EdgeInsets.zero),
            const _CardsSection(),
            SectionHeader(
              title: l10n.galleryIndicators,
              padding: EdgeInsets.zero,
            ),
            const _IndicatorsSection(),
            SectionHeader(title: l10n.galleryStates, padding: EdgeInsets.zero),
            const _StatesSection(),
            SectionHeader(
              title: l10n.galleryOverlays,
              padding: EdgeInsets.zero,
            ),
            const _OverlaysSection(),
            SectionHeader(
              title: l10n.galleryNavigation,
              padding: EdgeInsets.zero,
            ),
            const _NavigationSection(),
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: AppSpacing.md);
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.commonContinue;
    return Column(
      children: [
        AppButton(
          label: label,
          onPressed: () {},
          icon: Icons.play_arrow_rounded,
        ),
        const _Gap(),
        AppButton(
          label: label,
          onPressed: () {},
          variant: AppButtonVariant.secondary,
        ),
        const _Gap(),
        AppButton(
          label: label,
          onPressed: () {},
          variant: AppButtonVariant.text,
        ),
        const _Gap(),
        AppButton(
          label: context.l10n.commonDelete,
          onPressed: () {},
          variant: AppButtonVariant.destructive,
        ),
        const _Gap(),
        AppButton(label: label, onPressed: () {}, isLoading: true),
        const _Gap(),
        AppButton(label: label, onPressed: null),
        const _Gap(),
      ],
    );
  }
}

class _InputsSection extends StatelessWidget {
  const _InputsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        AppTextField(
          label: l10n.authFieldName,
          prefixIcon: Icons.person_outline,
        ),
        const _Gap(),
        AppTextField(
          label: l10n.authFieldPhone,
          forceLtr: true,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const _Gap(),
        AppTextField(label: l10n.authFieldPassword, isPassword: true),
        const _Gap(),
        AppTextField(
          label: l10n.authFieldEmail,
          errorText: l10n.validationEmail,
        ),
        const _Gap(),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget card(CourseCardVariant variant, {double? progress}) => CourseCard(
      title: l10n.gallerySampleCourse,
      teacherName: l10n.gallerySampleTeacher,
      rating: 4.8,
      progress: progress,
      variant: variant,
      priceSlot: const PriceView(price: 12.5, oldPrice: 20),
      discountSlot: const DiscountBadge(percent: 38),
      onTap: () {},
    );
    return Column(
      children: [
        SizedBox(
          width: AppSizes.courseCardWidth,
          child: card(CourseCardVariant.vertical, progress: 0.4),
        ),
        const _Gap(),
        card(CourseCardVariant.horizontal, progress: 0.72),
        const _Gap(),
        SizedBox(
          width: AppSizes.courseCardCompactWidth,
          child: card(CourseCardVariant.compact),
        ),
        const _Gap(),
        Row(
          children: [
            TeacherAvatarCard(
              name: l10n.gallerySampleTeacher,
              specialization: l10n.gallerySampleText,
              rating: 4.9,
              isVerified: true,
              onTap: () {},
            ),
            const Spacer(),
            const PriceView(price: 0, isFree: true, large: true),
          ],
        ),
        const _Gap(),
      ],
    );
  }
}

class _IndicatorsSection extends StatelessWidget {
  const _IndicatorsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            RatingChip(rating: 4.7),
            StatChip(icon: Icons.people_alt_rounded, label: '1.2K'),
            StatChip(icon: Icons.schedule_rounded, label: '12'),
          ],
        ),
        _Gap(),
        Wrap(
          spacing: AppSpacing.xl,
          children: [
            ProgressRing(progress: 0.25),
            ProgressRing(progress: 0.68),
            ProgressRing(progress: 1),
          ],
        ),
        _Gap(),
        Wrap(
          spacing: AppSpacing.xl,
          children: [
            ScoreGauge(fraction: 0.86, isPassed: true, size: 150),
            ScoreGauge(fraction: 0.32, isPassed: false, size: 150),
          ],
        ),
        _Gap(),
        Wrap(
          spacing: AppSpacing.md,
          children: [
            ExamTimer(
              remaining: Duration(minutes: 40),
              total: Duration(minutes: 60),
            ),
            ExamTimer(
              remaining: Duration(minutes: 20),
              total: Duration(minutes: 60),
            ),
            ExamTimer(
              remaining: Duration(minutes: 5),
              total: Duration(minutes: 60),
            ),
          ],
        ),
        _Gap(),
      ],
    );
  }
}

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: EmptyState(actionLabel: l10n.commonRetry, onAction: () {}),
        ),
        SizedBox(
          height: 340,
          child: ErrorState(message: l10n.errorNoInternet, onRetry: () {}),
        ),
        SizedBox(
          height: 380,
          child: SignInGate(onSignIn: () {}, onCreateAccount: () {}),
        ),
        const OfflineBanner(visible: true),
        const _Gap(),
        SectionHeader(title: l10n.galleryLoading, padding: EdgeInsets.zero),
        const SkeletonList(
          shrinkWrap: true,
          itemCount: 2,
          padding: EdgeInsets.zero,
          itemBuilder: _skeletonRow,
        ),
      ],
    );
  }

  static Widget _skeletonRow(BuildContext context) => const SkeletonRow();
}

class _OverlaysSection extends StatelessWidget {
  const _OverlaysSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        AppButton(
          label: l10n.galleryShowSheet,
          variant: AppButtonVariant.secondary,
          onPressed: () => showAppBottomSheet<void>(
            context,
            title: l10n.galleryTitle,
            builder: (_) => Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
              child: Text(l10n.gallerySampleMessage),
            ),
          ),
        ),
        const _Gap(),
        AppButton(
          label: l10n.galleryShowDialog,
          variant: AppButtonVariant.secondary,
          onPressed: () => showConfirmDialog(
            context,
            title: l10n.galleryTitle,
            message: l10n.gallerySampleMessage,
            confirmLabel: l10n.commonConfirm,
            icon: Icons.help_outline_rounded,
          ),
        ),
        const _Gap(),
        AppButton(
          label: l10n.galleryShowSnackbar,
          variant: AppButtonVariant.secondary,
          onPressed: () => AppSnackbar.show(
            context,
            l10n.gallerySampleMessage,
            type: AppSnackbarType.success,
          ),
        ),
        const _Gap(),
      ],
    );
  }
}

class _NavigationSection extends StatefulWidget {
  const _NavigationSection();

  @override
  State<_NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<_NavigationSection> {
  int _tab = 0;
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        AppSegmentedControl<int>(
          segments: {0: l10n.navHome, 1: l10n.navExplore, 2: l10n.navLibrary},
          selected: _segment,
          onChanged: (value) => setState(() => _segment = value),
        ),
        const _Gap(),
        AppBottomNav(
          currentIndex: _tab,
          onTap: (value) => setState(() => _tab = value),
          items: [
            AppNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: l10n.navHome,
            ),
            AppNavItem(
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              label: l10n.navExplore,
            ),
            AppNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: l10n.navProfile,
            ),
          ],
        ),
      ],
    );
  }
}
