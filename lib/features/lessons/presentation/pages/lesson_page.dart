import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/core/services/screen_security.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/design_system/components/app_button.dart';
import 'package:ibnzaidon/design_system/components/layout_helpers.dart';
import 'package:ibnzaidon/design_system/components/overlays.dart';
import 'package:ibnzaidon/design_system/components/skeleton.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/design_system/tokens/app_palette.dart';
import 'package:ibnzaidon/design_system/tokens/app_tokens.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/lessons/presentation/bloc/lesson_player_bloc.dart';
import 'package:ibnzaidon/features/lessons/presentation/widgets/youtube_lesson_player.dart';
import 'package:ibnzaidon/features/library/presentation/widgets/pdf_document_view.dart';
import 'package:ibnzaidon/shared/presentation/failure_view.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonPage extends StatelessWidget {
  const LessonPage({required this.courseId, required this.lessonId, super.key});

  final int courseId;
  final int lessonId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<LessonPlayerBloc>(param1: courseId, param2: lessonId)
            ..add(const LessonRequested()),
      child: _LessonView(courseId: courseId),
    );
  }
}

class _LessonView extends StatefulWidget {
  const _LessonView({required this.courseId});

  final int courseId;

  @override
  State<_LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<_LessonView> {
  late final ScreenSecurity _security = getIt<ScreenSecurity>();
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _security.enable();
  }

  @override
  void dispose() {
    if (_isFullScreen) _setOrientationAndChrome(fullScreen: false);
    _security.disable();
    super.dispose();
  }

  /// Toggling `youtube_player_flutter`'s own fullscreen mode only resizes
  /// the player widget — it doesn't touch this page's AppBar, orientation,
  /// or system bars, which is what actually makes fullscreen feel
  /// fullscreen. So this page owns that state itself and swaps its own
  /// Scaffold instead.
  void _setOrientationAndChrome({required bool fullScreen}) {
    if (fullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullScreen() {
    final next = !_isFullScreen;
    setState(() => _isFullScreen = next);
    _setOrientationAndChrome(fullScreen: next);
  }

  void _showForbidden(BuildContext context, String? serverMessage) {
    final l10n = context.l10n;
    showAppBottomSheet<void>(
      context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IllustrationBadge(
              icon: Icons.lock_rounded,
              tone: IllustrationTone.warning,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.lessonForbiddenTitle, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              serverMessage ?? l10n.lessonForbiddenFallback,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.lessonBackToCourse,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.course(widget.courseId));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonPlayerBloc, LessonPlayerState>(
      listenWhen: (previous, current) =>
          previous.isForbidden != current.isForbidden && current.isForbidden,
      listener: (context, state) =>
          _showForbidden(context, state.failure?.message),
      builder: (context, state) {
        final content = _body(context, state);
        if (_isFullScreen) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              // Back while fullscreen exits fullscreen first, matching the
              // native YouTube app, instead of leaving the lesson outright.
              if (!didPop) _toggleFullScreen();
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(child: content),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.lesson?.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: content,
        );
      },
    );
  }

  Widget _body(BuildContext context, LessonPlayerState state) {
    if (state.isLoading) return const _LessonSkeleton();
    final lesson = state.lesson;
    if (lesson == null) {
      if (state.isForbidden) {
        return const Center(
          child: IllustrationBadge(
            icon: Icons.lock_rounded,
            tone: IllustrationTone.warning,
          ),
        );
      }
      return FailureView(
        failure: state.failure!,
        onRetry: () =>
            context.read<LessonPlayerBloc>().add(const LessonRequested()),
      );
    }
    return switch (lesson.type) {
      LessonType.video => _VideoLesson(
        state: state,
        courseId: widget.courseId,
        isFullScreen: _isFullScreen,
        onToggleFullScreen: _toggleFullScreen,
      ),
      LessonType.pdf => _PdfLesson(state: state),
      LessonType.other => _OtherLesson(state: state),
    };
  }
}

class _VideoLesson extends StatelessWidget {
  const _VideoLesson({
    required this.state,
    required this.courseId,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  final LessonPlayerState state;
  final int courseId;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  @override
  Widget build(BuildContext context) {
    final url = state.lesson!.videoUrl;
    if (url == null) {
      return ErrorState(
        message: context.l10n.lessonNoVideo,
        icon: Icons.videocam_off_rounded,
      );
    }
    return YoutubeLessonPlayer(
      videoUrl: url,
      startSeconds: state.resumeSeconds,
      isFullScreen: isFullScreen,
      onToggleFullScreen: onToggleFullScreen,
      builder: (context, player) => isFullScreen
          ? Center(child: player)
          : ContentConstraint(
              maxWidth: 960,
              child: ListView(
                children: [
                  player,
                  _LessonInfo(state: state),
                  LessonNavigation(state: state, courseId: courseId),
                ],
              ),
            ),
    );
  }
}

class _PdfLesson extends StatelessWidget {
  const _PdfLesson({required this.state});

  final LessonPlayerState state;

  @override
  Widget build(BuildContext context) {
    final url = state.lesson!.fileUrl;
    final l10n = context.l10n;
    if (url == null) {
      return ErrorState(
        message: l10n.lessonNoFile,
        icon: Icons.description_outlined,
      );
    }
    return Column(
      children: [
        Expanded(child: PdfDocumentView(url: url)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: state.isCompleted
                ? _CompletedBadge(label: l10n.lessonCompleted)
                : AppButton(
                    label: l10n.lessonMarkComplete,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () => context.read<LessonPlayerBloc>().add(
                      const LessonMarkedComplete(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _OtherLesson extends StatelessWidget {
  const _OtherLesson({required this.state});

  final LessonPlayerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final url = state.lesson!.fileUrl ?? state.lesson!.videoUrl;
    return ContentConstraint(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
        children: [
          _LessonInfo(state: state),
          if (url != null)
            AppButton(
              label: l10n.lessonOpenFile,
              icon: Icons.open_in_new_rounded,
              onPressed: () => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (!state.isCompleted)
            AppButton(
              label: l10n.lessonMarkComplete,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.read<LessonPlayerBloc>().add(
                const LessonMarkedComplete(),
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonInfo extends StatelessWidget {
  const _LessonInfo({required this.state});

  final LessonPlayerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lesson = state.lesson!;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: context.text.titleLarge),
          if (state.resumeSeconds > 0 && !state.isCompleted)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
              child: Text(
                '${l10n.lessonResumeFrom} · ${AppFormatters.clock(Duration(seconds: state.resumeSeconds))}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          if (state.coursePercentage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.lessonCoursePercent(
                AppFormatters.percent(state.coursePercentage!),
              ),
              style: context.text.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadii.pillRadius,
              child: LinearProgressIndicator(value: state.coursePercentage),
            ),
          ],
          if (state.isCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            _CompletedBadge(label: l10n.lessonCompleted),
          ],
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.label});

  final String label;

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
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: palette.success),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: palette.onSuccessContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Previous / next lesson buttons (locked neighbours are disabled).
class LessonNavigation extends StatelessWidget {
  const LessonNavigation({
    required this.state,
    required this.courseId,
    super.key,
  });

  final LessonPlayerState state;
  final int courseId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final previous = state.previousLesson;
    final next = state.nextLesson;
    void go(int id) => context.pushReplacement(AppRoutes.lesson(courseId, id));
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.gutter,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.lessonPrevious,
              variant: AppButtonVariant.secondary,
              onPressed: previous == null ? null : () => go(previous.id),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              label: l10n.lessonNext,
              onPressed: next == null || next.isLocked
                  ? null
                  : () => go(next.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonSkeleton extends StatelessWidget {
  const _LessonSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: SkeletonBox(height: double.infinity, radius: 0),
        ),
        Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 24),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(width: 160, height: 16),
            ],
          ),
        ),
      ],
    ),
  );
}
