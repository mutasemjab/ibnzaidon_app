/// Route paths. Builders keep id interpolation in one place.
abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  static const home = '/home';
  static const explore = '/explore';
  static const myCourses = '/my-courses';
  static const library = '/library';
  static const profile = '/profile';

  static const courses = '/courses';
  static const exams = '/exams';
  static const myExams = '/my-exams';
  static const teachers = '/teachers';
  static const notifications = '/notifications';
  static const notificationPermission = '/notification-permission';
  static const settings = '/settings';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const pdfViewer = '/pdf-viewer';
  static const designGallery = '/design-gallery';

  static const announcements = '/announcements';
  static const conduct = '/conduct';
  static const planner = '/planner';
  static const schedules = '/schedules';

  static const categoryPattern = '/category/:id';
  static const subjectPattern = '/subject/:id';
  static const coursePattern = '/course/:id';
  static const lessonPattern = '/course/:courseId/lesson/:lessonId';
  static const examPattern = '/exam/:id';
  static const examTakePattern = '/exam/:id/take';
  static const examResultPattern = '/exam/:id/result';
  static const teacherPattern = '/teacher/:id';

  static String category(int id) => '/category/$id';
  static String subject(int id) => '/subject/$id';
  static String course(int id) => '/course/$id';
  static String lesson(int courseId, int lessonId) =>
      '/course/$courseId/lesson/$lessonId';
  static String exam(int id) => '/exam/$id';
  static String examTake(int id) => '/exam/$id/take';
  static String examResult(int id) => '/exam/$id/result';
  static String teacher(int id) => '/teacher/$id';

  /// Pages that only make sense signed in. Guests are sent to login with a
  /// `from` return path instead of seeing a broken screen.
  static bool requiresAuth(String location) =>
      location.startsWith('/exam/') && location.contains('/take') ||
      location.contains('/lesson/') ||
      location == notifications ||
      location == editProfile ||
      location == changePassword ||
      location == myExams;

  static bool isAuthFlow(String location) =>
      location == login || location == register;

  static bool isBootstrap(String location) =>
      location == splash || location == onboarding;
}
