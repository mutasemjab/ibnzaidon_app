import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/di/injector.dart';
import 'package:ibnzaidon/features/app_settings/data/repositories/app_settings_repository_impl.dart';
import 'package:ibnzaidon/features/app_settings/domain/repositories/app_settings_repository.dart';
import 'package:ibnzaidon/features/app_settings/domain/usecases/app_settings_usecases.dart';
import 'package:ibnzaidon/features/app_settings/presentation/bloc/app_settings_cubit.dart';
import 'package:ibnzaidon/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ibnzaidon/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ibnzaidon/features/auth/domain/repositories/auth_repository.dart';
import 'package:ibnzaidon/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ibnzaidon/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ibnzaidon/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:ibnzaidon/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:ibnzaidon/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:ibnzaidon/features/catalog/domain/usecases/catalog_usecases.dart';
import 'package:ibnzaidon/features/catalog/presentation/bloc/catalog_blocs.dart';
import 'package:ibnzaidon/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:ibnzaidon/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:ibnzaidon/features/courses/data/services/store_kit_purchase_gateway.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/repositories/courses_repository.dart';
import 'package:ibnzaidon/features/courses/domain/services/store_purchase_gateway.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/activation_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/course_detail_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:ibnzaidon/features/courses/presentation/bloc/purchase_bloc.dart';
import 'package:ibnzaidon/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:ibnzaidon/features/exams/domain/entities/exam_entities.dart';
import 'package:ibnzaidon/features/exams/domain/repositories/exams_repository.dart';
import 'package:ibnzaidon/features/exams/domain/usecases/exams_usecases.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exam_taking_bloc.dart';
import 'package:ibnzaidon/features/exams/presentation/bloc/exams_blocs.dart';
import 'package:ibnzaidon/features/home/data/repositories/home_repository_impl.dart';
import 'package:ibnzaidon/features/home/domain/repositories/home_repository.dart';
import 'package:ibnzaidon/features/home/domain/usecases/get_home_use_case.dart';
import 'package:ibnzaidon/features/home/presentation/bloc/home_bloc.dart';
import 'package:ibnzaidon/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:ibnzaidon/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:ibnzaidon/features/lessons/domain/usecases/lessons_usecases.dart';
import 'package:ibnzaidon/features/lessons/presentation/bloc/lesson_player_bloc.dart';
import 'package:ibnzaidon/features/library/data/repositories/library_repository_impl.dart';
import 'package:ibnzaidon/features/library/data/repositories/pdf_file_repository_impl.dart';
import 'package:ibnzaidon/features/library/domain/entities/library_item.dart';
import 'package:ibnzaidon/features/library/domain/repositories/library_repositories.dart';
import 'package:ibnzaidon/features/library/domain/usecases/library_usecases.dart';
import 'package:ibnzaidon/features/library/presentation/bloc/library_bloc.dart';
import 'package:ibnzaidon/features/library/presentation/bloc/pdf_file_cubit.dart';
import 'package:ibnzaidon/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:ibnzaidon/features/notifications/data/services/firebase_push_messaging_service.dart';
import 'package:ibnzaidon/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:ibnzaidon/features/notifications/domain/services/push_messaging_service.dart';
import 'package:ibnzaidon/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/push_setup_cubit.dart';
import 'package:ibnzaidon/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ibnzaidon/features/profile/domain/repositories/profile_repository.dart';
import 'package:ibnzaidon/features/profile/domain/usecases/profile_usecases.dart';
import 'package:ibnzaidon/features/profile/presentation/bloc/profile_blocs.dart';
import 'package:ibnzaidon/features/school_life/data/school_life_repository_impl.dart';
import 'package:ibnzaidon/features/school_life/domain/entities/school_record.dart';
import 'package:ibnzaidon/features/school_life/domain/repositories/school_life_repository.dart';
import 'package:ibnzaidon/features/school_life/domain/usecases/school_life_usecases.dart';
import 'package:ibnzaidon/features/school_life/presentation/bloc/school_life_blocs.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:ibnzaidon/features/splash_onboarding/presentation/bloc/splash_cubit.dart';
import 'package:ibnzaidon/features/teachers/data/datasources/teachers_remote_data_source.dart';
import 'package:ibnzaidon/features/teachers/data/repositories/teachers_repository_impl.dart';
import 'package:ibnzaidon/features/teachers/domain/repositories/teachers_repository.dart';
import 'package:ibnzaidon/features/teachers/domain/usecases/teachers_usecases.dart';
import 'package:ibnzaidon/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Repositories, use cases and blocs. Global blocs are singletons; screen
/// blocs are factories created (and closed) by their route.
void registerFeatureModules() {
  _registerAppSettings();
  _registerAuth();
  _registerCatalog();
  _registerHome();
  _registerCourses();
  _registerLessons();
  _registerExams();
  _registerTeachers();
  _registerLibrary();
  _registerNotifications();
  _registerProfile();
  _registerSchoolLife();
  _registerSplashOnboarding();
}

void _registerAppSettings() {
  getIt
    ..registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepositoryImpl(
        client: getIt(),
        store: getIt(),
        guard: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAppSettingsUseCase(getIt()))
    ..registerLazySingleton(() => ReadLastKnownAppSettingsUseCase(getIt()))
    ..registerLazySingleton<AppSettingsCubit>(
      () => AppSettingsCubit(getAppSettings: getIt(), readLastKnown: getIt()),
    );
}

void _registerAuth() {
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        secureStorage: getIt(),
        store: getIt(),
        cache: getIt(),
        guard: getIt(),
      ),
    )
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => RegisterUseCase(getIt()))
    ..registerLazySingleton(() => RestoreSessionUseCase(getIt()))
    ..registerLazySingleton(() => LogoutUseCase(getIt()))
    ..registerLazySingleton(() => DeleteAccountUseCase(getIt()))
    ..registerLazySingleton(() => SwitchSiblingUseCase(getIt()))
    ..registerLazySingleton(() => ClearLocalSessionUseCase(getIt()))
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        restoreSession: getIt(),
        clearLocalSession: getIt(),
        sessionExpiry: getIt(),
      ),
    )
    ..registerFactory(() => LoginBloc(getIt(), getIt()))
    ..registerFactory(() => RegisterBloc(getIt()));
}

void _registerCatalog() {
  getIt
    ..registerLazySingleton(() => CatalogRemoteDataSource(getIt()))
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        remote: getIt(),
        cache: getIt(),
        guard: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetBannersUseCase(getIt()))
    ..registerLazySingleton(() => GetCategoriesUseCase(getIt()))
    ..registerLazySingleton(() => GetCategoryDetailUseCase(getIt()))
    ..registerLazySingleton(() => GetSubjectDetailUseCase(getIt()))
    ..registerFactory(() => BannersBloc(getIt()))
    ..registerFactory(() => CategoriesBloc(getIt()))
    ..registerFactoryParam<CategoryDetailBloc, int, void>(
      (id, _) => CategoryDetailBloc(getIt(), categoryId: id),
    )
    ..registerFactoryParam<SubjectDetailBloc, int, void>(
      (id, _) => SubjectDetailBloc(getIt(), subjectId: id),
    );
}

void _registerHome() {
  getIt
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(client: getIt(), cache: getIt(), guard: getIt()),
    )
    ..registerLazySingleton(() => GetHomeUseCase(getIt()))
    ..registerFactory(() => HomeBloc(getIt()));
}

void _registerCourses() {
  getIt
    ..registerLazySingleton(() => CoursesRemoteDataSource(getIt()))
    ..registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(
        remote: getIt(),
        cache: getIt(),
        guard: getIt(),
      ),
    )
    ..registerLazySingleton<StorePurchaseGateway>(
      () => Platform.isIOS
          ? StoreKitPurchaseGateway(InAppPurchase.instance)
          : const NoStorePurchaseGateway(),
    )
    ..registerLazySingleton(() => GetCoursesUseCase(getIt()))
    ..registerLazySingleton(() => GetCourseDetailUseCase(getIt()))
    ..registerLazySingleton(() => GetCourseUnitsUseCase(getIt()))
    ..registerLazySingleton(() => GetCourseProgressUseCase(getIt()))
    ..registerLazySingleton(() => GetMyCoursesUseCase(getIt()))
    ..registerLazySingleton(() => ActivateCourseUseCase(getIt()))
    ..registerLazySingleton(() => VerifyApplePurchaseUseCase(getIt()))
    ..registerFactoryParam<CoursesBloc, CourseQuery?, void>(
      (query, _) =>
          CoursesBloc(getIt(), initialQuery: query ?? const CourseQuery()),
    )
    ..registerFactory(() => MyCoursesBloc(getIt()))
    ..registerFactoryParam<CourseDetailBloc, int, void>(
      (id, _) => CourseDetailBloc(
        courseId: id,
        getCourseDetail: getIt(),
        getCourseUnits: getIt(),
        getCourseProgress: getIt(),
      ),
    )
    ..registerFactoryParam<ActivationBloc, int, void>(
      (id, _) => ActivationBloc(courseId: id, activateCourse: getIt()),
    )
    ..registerLazySingleton<PurchaseBloc>(
      () => PurchaseBloc(
        gateway: getIt(),
        verifyPurchase: getIt(),
        config: getIt<AppConfig>(),
        appAccountToken: () => getIt<AuthBloc>().state.student?.appAccountToken,
      ),
    );
}

void _registerLessons() {
  getIt
    ..registerLazySingleton<LessonsRepository>(
      () => LessonsRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton(() => GetLessonUseCase(getIt()))
    ..registerLazySingleton(() => ReportLessonProgressUseCase(getIt()))
    ..registerFactoryParam<LessonPlayerBloc, int, int>(
      (courseId, lessonId) => LessonPlayerBloc(
        courseId: courseId,
        lessonId: lessonId,
        getLesson: getIt(),
        reportProgress: getIt(),
        getCourseUnits: getIt(),
        getCourseProgress: getIt(),
      ),
    );
}

void _registerExams() {
  getIt
    ..registerLazySingleton<ExamsRepository>(
      () => ExamsRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton<ExamDraftRepository>(
      () => ExamDraftRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetExamsUseCase(getIt()))
    ..registerLazySingleton(() => GetExamDetailUseCase(getIt()))
    ..registerLazySingleton(() => StartExamUseCase(getIt()))
    ..registerLazySingleton(() => SubmitAttemptUseCase(getIt()))
    ..registerLazySingleton(() => GetMyExamsUseCase(getIt()))
    ..registerLazySingleton(() => ExamDraftUseCases(getIt()))
    ..registerFactoryParam<ExamsBloc, ExamQuery?, void>(
      (query, _) =>
          ExamsBloc(getIt(), initialQuery: query ?? const ExamQuery()),
    )
    ..registerFactory(() => MyExamsBloc(getIt()))
    ..registerFactoryParam<ExamDetailBloc, int, void>(
      (id, _) => ExamDetailBloc(getIt(), examId: id),
    )
    ..registerFactoryParam<ExamTakingBloc, int, void>(
      (id, _) => ExamTakingBloc(
        examId: id,
        startExam: getIt(),
        submitAttempt: getIt(),
        drafts: getIt(),
      ),
    );
}

void _registerTeachers() {
  getIt
    ..registerLazySingleton(() => TeachersRemoteDataSource(getIt()))
    ..registerLazySingleton<TeachersRepository>(
      () => TeachersRepositoryImpl(remote: getIt(), guard: getIt()),
    )
    ..registerLazySingleton(() => GetTeachersUseCase(getIt()))
    ..registerLazySingleton(() => GetTeacherDetailUseCase(getIt()))
    ..registerFactory(() => TeachersBloc(getIt()))
    ..registerFactoryParam<TeacherDetailBloc, int, void>(
      (id, _) => TeacherDetailBloc(getIt(), teacherId: id),
    );
}

void _registerLibrary() {
  getIt
    ..registerLazySingleton<LibraryRepository>(
      () => LibraryRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton<PdfFileRepository>(
      () => PdfFileRepositoryImpl(
        client: getIt(),
        guard: getIt(),
        crashReporter: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetLibraryItemsUseCase(getIt()))
    ..registerLazySingleton(() => GetCachedPdfUseCase(getIt()))
    ..registerLazySingleton(() => DownloadPdfUseCase(getIt()))
    ..registerFactoryParam<LibraryBloc, LibraryKind, void>(
      (kind, _) => LibraryBloc(getIt(), kind: kind),
    )
    ..registerFactoryParam<PdfFileCubit, String, void>(
      (url, _) => PdfFileCubit(
        url: url,
        getCached: getIt(),
        download: getIt(),
      ),
    );
}

void _registerNotifications() {
  getIt
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton<PushMessagingService>(
      () => FirebasePushMessagingService(
        FirebaseMessaging.instance,
        FlutterLocalNotificationsPlugin(),
      ),
    )
    ..registerLazySingleton(() => GetNotificationsUseCase(getIt()))
    ..registerLazySingleton(() => MarkNotificationReadUseCase(getIt()))
    ..registerLazySingleton(() => MarkAllNotificationsReadUseCase(getIt()))
    ..registerLazySingleton(() => RegisterDeviceTokenUseCase(getIt()))
    ..registerFactory(
      () => NotificationsBloc(
        getNotifications: getIt(),
        markRead: getIt(),
        markAllRead: getIt(),
      ),
    )
    ..registerLazySingleton<NotificationsBadgeCubit>(
      () => NotificationsBadgeCubit(getIt()),
    )
    ..registerLazySingleton<PushSetupCubit>(
      () => PushSetupCubit(
        service: getIt(),
        registerToken: getIt(),
        store: getIt(),
      ),
    );
}

void _registerProfile() {
  getIt
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(getIt()))
    ..registerLazySingleton(() => UpdateProfileUseCase(getIt()))
    ..registerLazySingleton(() => ChangePasswordUseCase(getIt()))
    ..registerFactory(() => ProfileBloc(getIt()))
    ..registerFactory(() => ProfileEditBloc(getIt()))
    ..registerFactory(() => PasswordChangeBloc(getIt()))
    ..registerFactory(
      () => AccountBloc(logout: getIt(), deleteAccount: getIt()),
    );
}

void _registerSchoolLife() {
  getIt
    ..registerLazySingleton<SchoolLifeRepository>(
      () => SchoolLifeRepositoryImpl(client: getIt(), guard: getIt()),
    )
    ..registerLazySingleton(() => GetSchoolRecordsUseCase(getIt()))
    ..registerLazySingleton(() => GetAnnouncementUseCase(getIt()))
    ..registerLazySingleton(() => GetConductUseCase(getIt()))
    ..registerLazySingleton(() => SignConductUseCase(getIt()))
    ..registerFactoryParam<SchoolRecordsBloc, SchoolRecordKind, void>(
      (kind, _) => SchoolRecordsBloc(getIt(), kind: kind),
    )
    ..registerFactory(
      () => ConductBloc(getConduct: getIt(), signConduct: getIt()),
    );
}

void _registerSplashOnboarding() {
  getIt
    ..registerFactory(
      () => SplashCubit(authBloc: getIt(), flowStore: getIt()),
    )
    ..registerFactory(() => OnboardingCubit(getIt()));
}
