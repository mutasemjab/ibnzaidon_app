import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ibnzaidon/app/router/app_routes.dart';
import 'package:ibnzaidon/app/shell/main_shell.dart';
import 'package:ibnzaidon/core/config/feature_flags.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/design_system/gallery/design_gallery_page.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/pages/login_page.dart';
import 'package:ibnzaidon/features/auth/presentation/pages/register_page.dart';
import 'package:ibnzaidon/features/catalog/presentation/pages/category_page.dart';
import 'package:ibnzaidon/features/catalog/presentation/pages/explore_page.dart';
import 'package:ibnzaidon/features/catalog/presentation/pages/subject_page.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/presentation/pages/course_detail_page.dart';
import 'package:ibnzaidon/features/courses/presentation/pages/courses_page.dart';
import 'package:ibnzaidon/features/courses/presentation/pages/my_courses_page.dart';
import 'package:ibnzaidon/features/exams/presentation/pages/exam_detail_page.dart';
import 'package:ibnzaidon/features/exams/presentation/pages/exam_result_page.dart';
import 'package:ibnzaidon/features/exams/presentation/pages/exam_taking_page.dart';
import 'package:ibnzaidon/features/exams/presentation/pages/exams_pages.dart';
import 'package:ibnzaidon/features/home/presentation/pages/home_page.dart';
import 'package:ibnzaidon/features/lessons/presentation/pages/lesson_page.dart';
import 'package:ibnzaidon/features/library/presentation/pages/library_page.dart';
import 'package:ibnzaidon/features/library/presentation/pages/pdf_viewer_page.dart';
import 'package:ibnzaidon/features/notifications/presentation/pages/notification_permission_page.dart';
import 'package:ibnzaidon/features/notifications/presentation/pages/notifications_page.dart';
import 'package:ibnzaidon/features/profile/presentation/pages/change_password_page.dart';
import 'package:ibnzaidon/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:ibnzaidon/features/profile/presentation/pages/profile_page.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/presentation/pages/school_life_pages.dart';
import 'package:ibnzaidon/features/settings/presentation/pages/settings_page.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/pages/onboarding_page.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/pages/splash_page.dart';
import 'package:ibnzaidon/features/teachers/presentation/pages/teacher_page.dart';
import 'package:ibnzaidon/features/teachers/presentation/pages/teachers_page.dart';

/// Rebuilds the router's redirect when the session changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

abstract final class AppRouter {
  static GoRouter create({
    required AuthBloc authBloc,
    required FeatureFlags flags,
    required bool showDesignGallery,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _AuthRefresh(authBloc.stream),
      redirect: (context, state) => _redirect(authBloc.state, state),
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, state) =>
              LoginPage(returnTo: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, state) =>
              RegisterPage(returnTo: state.uri.queryParameters['from']),
        ),
        _shell(),
        GoRoute(
          path: AppRoutes.courses,
          builder: (_, state) => CoursesPage(
            initialQuery: _courseQuery(state.uri.queryParameters),
          ),
        ),
        GoRoute(
          path: AppRoutes.categoryPattern,
          builder: (_, state) => CategoryPage(
            categoryId: _id(state, 'id'),
            trail: state.extra is List<String>
                ? state.extra! as List<String>
                : const [],
          ),
        ),
        GoRoute(
          path: AppRoutes.subjectPattern,
          builder: (_, state) => SubjectPage(subjectId: _id(state, 'id')),
        ),
        GoRoute(
          path: AppRoutes.coursePattern,
          builder: (_, state) => CourseDetailPage(courseId: _id(state, 'id')),
        ),
        GoRoute(
          path: AppRoutes.lessonPattern,
          builder: (_, state) => LessonPage(
            courseId: _id(state, 'courseId'),
            lessonId: _id(state, 'lessonId'),
          ),
        ),
        GoRoute(path: AppRoutes.exams, builder: (_, _) => const ExamsPage()),
        GoRoute(
          path: AppRoutes.examPattern,
          builder: (_, state) => ExamDetailPage(examId: _id(state, 'id')),
        ),
        GoRoute(
          path: AppRoutes.examTakePattern,
          builder: (_, state) => ExamTakingPage(examId: _id(state, 'id')),
        ),
        GoRoute(
          path: AppRoutes.examResultPattern,
          // A result can only be shown with the attempt data; without it
          // (e.g. a stale deep link) fall back to the exam page.
          redirect: (_, state) => state.extra is ExamResultArgs
              ? null
              : AppRoutes.exam(_id(state, 'id')),
          builder: (_, state) =>
              ExamResultPage(args: state.extra! as ExamResultArgs),
        ),
        GoRoute(
          path: AppRoutes.myExams,
          builder: (_, _) => const MyExamsPage(),
        ),
        GoRoute(
          path: AppRoutes.teachers,
          builder: (_, _) => const TeachersPage(),
        ),
        GoRoute(
          path: AppRoutes.teacherPattern,
          builder: (_, state) => TeacherPage(teacherId: _id(state, 'id')),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.notificationPermission,
          builder: (_, _) => const NotificationPermissionPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (_, _) => const EditProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          builder: (_, _) => const ChangePasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.pdfViewer,
          redirect: (_, state) =>
              state.extra is PdfViewerArgs ? null : AppRoutes.library,
          builder: (_, state) =>
              PdfViewerPage(args: state.extra! as PdfViewerArgs),
        ),
        if (showDesignGallery)
          GoRoute(
            path: AppRoutes.designGallery,
            builder: (_, _) => const DesignGalleryPage(),
          ),
        ..._flaggedRoutes(flags),
      ],
    );
  }

  static String? _redirect(AuthState auth, GoRouterState state) {
    final location = state.matchedLocation;
    if (auth.status == AuthStatus.unknown) {
      return AppRoutes.isBootstrap(location) ? null : AppRoutes.splash;
    }
    if (auth.isAuthenticated && AppRoutes.isAuthFlow(location)) {
      return state.uri.queryParameters['from'] ?? AppRoutes.home;
    }
    if (!auth.isAuthenticated && AppRoutes.requiresAuth(location)) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '${AppRoutes.login}?from=$from';
    }
    return null;
  }

  static StatefulShellRoute _shell() => StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => MainShell(navigationShell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.explore,
            builder: (_, _) => const ExplorePage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.myCourses,
            builder: (_, _) => const MyCoursesPage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.library,
            builder: (_, _) => const LibraryPage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );

  /// Feature-flagged modules only get routes when their flag is on.
  static List<GoRoute> _flaggedRoutes(FeatureFlags flags) => [
    if (flags.announcements)
      GoRoute(
        path: AppRoutes.announcements,
        builder: (context, _) => SchoolRecordsPage(
          title: context.l10n.schoolAnnouncements,
          kinds: {
            SchoolRecordKind.announcements: context.l10n.schoolAnnouncements,
          },
        ),
      ),
    if (flags.conduct)
      GoRoute(path: AppRoutes.conduct, builder: (_, _) => const ConductPage()),
    if (flags.planners)
      GoRoute(
        path: AppRoutes.planner,
        builder: (context, _) => SchoolRecordsPage(
          title: context.l10n.schoolPlanner,
          kinds: {
            SchoolRecordKind.educationalNotes: context.l10n.schoolPlannerNotes,
            SchoolRecordKind.weeklyPlanner: context.l10n.schoolPlannerWeekly,
          },
        ),
      ),
    if (flags.schedules)
      GoRoute(
        path: AppRoutes.schedules,
        builder: (context, _) => SchoolRecordsPage(
          title: context.l10n.schoolSchedules,
          kinds: {
            SchoolRecordKind.classSchedule: context.l10n.schoolScheduleClass,
            SchoolRecordKind.examSchedule: context.l10n.schoolScheduleExam,
          },
        ),
      ),
  ];

  static int _id(GoRouterState state, String name) =>
      parseInt(state.pathParameters[name]);

  static CourseQuery _courseQuery(Map<String, String> params) => CourseQuery(
    search: params['search'] ?? '',
    categoryId: tryParseInt(params['category_id']),
    subjectId: tryParseInt(params['subject_id']),
    teacherId: tryParseInt(params['teacher_id']),
    featured: parseBool(params['featured']),
    trending: parseBool(params['trending']),
  );
}
