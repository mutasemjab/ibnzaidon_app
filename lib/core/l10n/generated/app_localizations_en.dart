// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ibn Zaidon Academy';

  @override
  String get appTagline => 'Learn smart, excel with confidence';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonNext => 'Next';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonDownload => 'Download';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonFilters => 'Filters';

  @override
  String get commonAll => 'All';

  @override
  String get commonFree => 'Free';

  @override
  String get commonLoadMoreFailed => 'Couldn\'t load more';

  @override
  String get commonPullToRefresh => 'Pull to refresh';

  @override
  String commonMinutes(int count) {
    return '$count min';
  }

  @override
  String commonHours(int count) {
    return '$count h';
  }

  @override
  String commonCoursesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
      zero: 'No courses',
    );
    return '$_temp0';
  }

  @override
  String commonStudentsCount(String count) {
    return '$count students';
  }

  @override
  String commonLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String commonQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
      zero: 'No questions',
    );
    return '$_temp0';
  }

  @override
  String get errorNoInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorUnauthorized =>
      'Your session has ended. Please sign in again.';

  @override
  String get errorForbidden => 'You don\'t have access to this content.';

  @override
  String get errorValidation => 'Please check the information you entered.';

  @override
  String get errorNotFound => 'We couldn\'t find what you\'re looking for.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Try again later.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Sign in again to continue.';

  @override
  String get errorStateTitle => 'Oops, something went wrong';

  @override
  String get offlineBanner => 'You\'re offline. Showing saved data.';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyMessage => 'Try changing your search or filters.';

  @override
  String get gateTitle => 'Sign in to continue';

  @override
  String get gateMessage =>
      'Create an account or sign in to access your courses, exams and progress.';

  @override
  String get gateSignIn => 'Sign in';

  @override
  String get gateCreateAccount => 'Create account';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMyCourses => 'My courses';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardingTitle1 => 'High-quality recorded courses';

  @override
  String get onboardingBody1 =>
      'Watch your lessons anytime, anywhere, and pick up right where you left off.';

  @override
  String get onboardingTitle2 => 'Exams with instant analysis';

  @override
  String get onboardingBody2 =>
      'Test yourself and see your strengths and weaknesses right after submitting.';

  @override
  String get onboardingTitle3 => 'Worksheets & past-exam library';

  @override
  String get onboardingBody3 =>
      'Download PDFs and practise with question banks and previous exams.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to continue your learning journey';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle => 'Join Ibn Zaidon Academy today';

  @override
  String get authFieldName => 'Full name';

  @override
  String get authFieldPhone => 'Phone number';

  @override
  String get authFieldEmail => 'Email (optional)';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authFieldPasswordConfirm => 'Confirm password';

  @override
  String get authFieldCurrentPassword => 'Current password';

  @override
  String get authFieldNewPassword => 'New password';

  @override
  String get authLoginAction => 'Sign in';

  @override
  String get authRegisterAction => 'Create account';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String get validationPasswordShort =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authInvalidCredentials => 'Incorrect phone number or password';

  @override
  String get authAccountSuspended =>
      'This account is suspended. Please contact support.';

  @override
  String authWelcomeName(String name) {
    return 'Hello, $name';
  }

  @override
  String get authWelcomeGuest => 'Welcome';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String examTimeRemaining(String time) {
    return 'Time remaining $time';
  }

  @override
  String get galleryTitle => 'Design gallery';

  @override
  String get galleryButtons => 'Buttons';

  @override
  String get galleryInputs => 'Inputs';

  @override
  String get galleryCards => 'Cards';

  @override
  String get galleryIndicators => 'Indicators';

  @override
  String get galleryStates => 'States';

  @override
  String get galleryOverlays => 'Overlays';

  @override
  String get galleryNavigation => 'Navigation';

  @override
  String get galleryLoading => 'Loading';

  @override
  String get galleryShowSheet => 'Show bottom sheet';

  @override
  String get galleryShowDialog => 'Show dialog';

  @override
  String get galleryShowSnackbar => 'Show snackbar';

  @override
  String get gallerySampleCourse => 'Grade 10 Mathematics Essentials';

  @override
  String get gallerySampleTeacher => 'Mr. Sami Haddad';

  @override
  String get gallerySampleText => 'Sample text';

  @override
  String get gallerySampleMessage =>
      'This is a sample message to preview the component';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'Search for a course...';

  @override
  String get exploreCategories => 'Categories';

  @override
  String get exploreSections => 'Sections';

  @override
  String get exploreSubjects => 'Subjects';

  @override
  String get exploreViewGrid => 'Grid view';

  @override
  String get exploreViewList => 'List view';

  @override
  String get exploreCategoryEmpty => 'No sections or subjects here yet';

  @override
  String get exploreSearchResults => 'Search results';

  @override
  String get exploreSearchSignIn => 'Sign in to search courses';

  @override
  String get subjectElective => 'Elective';

  @override
  String get subjectCoursesTitle => 'Courses in this subject';

  @override
  String get subjectNoCourses => 'No courses in this subject yet';

  @override
  String categorySubcategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sub-sections',
      one: '1 sub-section',
      zero: 'No sub-sections',
    );
    return '$_temp0';
  }

  @override
  String get coursesTitle => 'Courses';

  @override
  String get coursesEmptyTitle => 'No matching courses';

  @override
  String get coursesFiltersTitle => 'Filter courses';

  @override
  String get coursesFilterFeatured => 'Featured';

  @override
  String get coursesFilterTrending => 'Trending';

  @override
  String get coursesFilterCategory => 'Category';

  @override
  String get coursesFilterSubject => 'Subject';

  @override
  String get coursesFilterTeacher => 'Teacher';

  @override
  String coursesFiltersActive(int count) {
    return '$count filters active';
  }

  @override
  String get coursesSearchHint => 'Search courses';

  @override
  String get courseTabContent => 'Content';

  @override
  String get courseTabAbout => 'About';

  @override
  String get courseTabReviews => 'Reviews';

  @override
  String get courseReviewsPlaceholder => 'Student reviews are coming soon';

  @override
  String get courseWhatYouLearn => 'What you\'ll learn';

  @override
  String get courseRequirements => 'Requirements';

  @override
  String get courseDescription => 'Description';

  @override
  String get courseNoContent => 'No content has been added to this course yet';

  @override
  String get courseTeacher => 'Instructor';

  @override
  String get courseStudents => 'Students';

  @override
  String get courseDuration => 'Duration';

  @override
  String get courseLevel => 'Level';

  @override
  String courseVideos(int count) {
    return '$count videos';
  }

  @override
  String coursePdfs(int count) {
    return '$count PDFs';
  }

  @override
  String get courseLive => 'Live';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyIntermediate => 'Intermediate';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String courseUnitExams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exams',
      one: '1 exam',
    );
    return '$_temp0';
  }

  @override
  String get courseUnitExamsTitle => 'Unit exams';

  @override
  String courseExamMeta(int questions, int minutes) {
    return '$questions questions · $minutes min';
  }

  @override
  String get lessonFree => 'Free';

  @override
  String get lessonLockedTitle => 'Lesson locked';

  @override
  String get lessonLockedEnroll => 'Activate the course to access this lesson.';

  @override
  String get lessonLockedSequence =>
      'Finish the previous lesson first to unlock this one.';

  @override
  String get lessonTypeVideo => 'Video';

  @override
  String get lessonTypePdf => 'PDF';

  @override
  String get lessonTypeOther => 'Lesson';

  @override
  String get courseSequentialHint => 'Lessons in this course unlock in order';

  @override
  String get courseActionStartFree => 'Start learning';

  @override
  String get courseActionContinue => 'Continue learning';

  @override
  String get courseActionActivate => 'Activate with a card';

  @override
  String courseActionBuy(String price) {
    return 'Buy for $price';
  }

  @override
  String get courseActionSignIn => 'Sign in to enroll';

  @override
  String courseProgressLabel(String percent) {
    return '$percent complete';
  }

  @override
  String get activationTitle => 'Activate course';

  @override
  String get activationSubtitle => 'Enter the code printed on your card';

  @override
  String get activationCodeLabel => 'Card code';

  @override
  String get activationAction => 'Activate';

  @override
  String get activationSuccessTitle => 'Course activated!';

  @override
  String activationSuccessBody(String name) {
    return 'You now have access to “$name”.';
  }

  @override
  String get activationStart => 'Start now';

  @override
  String get activationFailed =>
      'Couldn\'t activate the card. Check the code and try again.';

  @override
  String get purchaseVerifying => 'Confirming your purchase…';

  @override
  String get purchaseSuccess => 'Course purchased successfully';

  @override
  String get purchasePending => 'Your purchase is awaiting approval';

  @override
  String get purchaseCancelled => 'Purchase cancelled';

  @override
  String get purchaseFailed => 'The purchase couldn\'t be completed';

  @override
  String get purchaseVerifyFailed =>
      'Payment went through but couldn\'t be confirmed. Retry — you won\'t be charged again.';

  @override
  String get purchaseRestore => 'Restore purchases';

  @override
  String get myCoursesTitle => 'My courses';

  @override
  String get myCoursesEmptyTitle => 'You haven\'t enrolled in any course yet';

  @override
  String get myCoursesEmptyBody =>
      'Browse courses and activate your card to get started.';

  @override
  String get myCoursesBrowse => 'Browse courses';

  @override
  String get myCoursesCompleted => 'Completed';

  @override
  String get myCoursesContinue => 'Continue';

  @override
  String get myCoursesGate => 'Sign in to see your courses and progress.';

  @override
  String get teachersTitle => 'Teachers';

  @override
  String get teachersSearchHint => 'Search teachers';

  @override
  String get teachersEmpty => 'No matching teachers';

  @override
  String get teacherVerified => 'Verified teacher';

  @override
  String teacherExperience(int years) {
    return '$years years of experience';
  }

  @override
  String get teacherQualification => 'Qualification';

  @override
  String get teacherAbout => 'About the teacher';

  @override
  String get teacherCoursesTitle => 'Teacher\'s courses';

  @override
  String get teacherNoCourses => 'This teacher has no courses yet';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryPreviousExams => 'Previous exams';

  @override
  String get libraryQuestionBanks => 'Question banks';

  @override
  String get libraryWorksheets => 'Worksheets';

  @override
  String get librarySearchHint => 'Search files';

  @override
  String get libraryYear => 'Year';

  @override
  String get librarySubject => 'Subject';

  @override
  String get libraryEmptyTitle => 'No files found';

  @override
  String libraryPages(int count) {
    return '$count pages';
  }

  @override
  String get libraryOpen => 'Open';

  @override
  String libraryDownloading(String percent) {
    return 'Downloading $percent';
  }

  @override
  String get libraryDownloaded => 'Saved for offline reading';

  @override
  String get libraryDownloadFailed => 'Couldn\'t download the file';

  @override
  String get libraryShareFile => 'Share file';

  @override
  String get pdfViewerFailed => 'Couldn\'t display the file';

  @override
  String pdfPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get lessonPrevious => 'Previous lesson';

  @override
  String get lessonNext => 'Next lesson';

  @override
  String get lessonMarkComplete => 'Mark as complete';

  @override
  String get lessonCompleted => 'Lesson completed';

  @override
  String get lessonResumeFrom => 'Resuming where you left off';

  @override
  String get lessonNoVideo => 'No video available for this lesson';

  @override
  String get lessonNoFile => 'No file available for this lesson';

  @override
  String get lessonOpenFile => 'Open file';

  @override
  String get lessonForbiddenTitle => 'You can\'t open this lesson yet';

  @override
  String get lessonForbiddenFallback =>
      'Activate the course or finish the previous lessons to continue.';

  @override
  String get lessonBackToCourse => 'Back to course';

  @override
  String lessonCoursePercent(String percent) {
    return 'Course progress $percent';
  }

  @override
  String get examsTitle => 'Exams';

  @override
  String get examsSearchHint => 'Search exams';

  @override
  String get examsEmptyTitle => 'No exams found';

  @override
  String get examsQuickAccess => 'Exams';

  @override
  String get examDetailTitle => 'Exam details';

  @override
  String examDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String examTotalMarks(String marks) {
    return '$marks marks';
  }

  @override
  String examPassMarks(String marks) {
    return 'Pass mark $marks';
  }

  @override
  String get examInstructions => 'Instructions';

  @override
  String get examRulesTitle => 'Before you start';

  @override
  String get examRuleTimer =>
      'The countdown starts as soon as you begin and never pauses.';

  @override
  String get examRuleAutosave =>
      'Your answers are saved automatically, even if the app closes.';

  @override
  String get examRuleAutoSubmit =>
      'The exam is submitted automatically when time runs out.';

  @override
  String get examStart => 'Start exam';

  @override
  String get examResume => 'Resume exam';

  @override
  String get examStartConfirmTitle => 'Start the exam?';

  @override
  String examStartConfirmBody(int minutes) {
    return 'You\'ll have $minutes minutes and the timer starts immediately.';
  }

  @override
  String get examSignInToStart => 'Sign in to start the exam';

  @override
  String examQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String examMarksLabel(String marks) {
    return '$marks marks';
  }

  @override
  String get examNavigator => 'Question navigator';

  @override
  String get examLegendAnswered => 'Answered';

  @override
  String get examLegendUnanswered => 'Unanswered';

  @override
  String get examLegendFlagged => 'Flagged';

  @override
  String get examFlag => 'Flag for review';

  @override
  String get examUnflag => 'Remove flag';

  @override
  String get examClearAnswer => 'Clear answer';

  @override
  String get examSubmit => 'Submit exam';

  @override
  String get examSubmitConfirmTitle => 'Submit the exam?';

  @override
  String examSubmitConfirmUnanswered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unanswered questions',
      one: '1 unanswered question',
    );
    return 'You have $_temp0. Submit anyway?';
  }

  @override
  String get examSubmitConfirmAll =>
      'You\'ve answered every question. Submit now?';

  @override
  String get examLeaveTitle => 'Leave the exam?';

  @override
  String get examLeaveBody =>
      'The timer keeps running and your answers are saved. You can come back to continue.';

  @override
  String get examLeaveConfirm => 'Leave';

  @override
  String get examTimeUpTitle => 'Time\'s up';

  @override
  String get examTimeUpBody => 'Submitting your answers automatically…';

  @override
  String get examSubmitFailed =>
      'Couldn\'t submit the exam. Your answers are safe — try again.';

  @override
  String get examSubmitting => 'Submitting…';

  @override
  String get examNoQuestions => 'This exam has no questions';

  @override
  String get examResultTitle => 'Exam result';

  @override
  String get examPassed => 'Passed';

  @override
  String get examFailed => 'Not passed';

  @override
  String get examCongrats => 'Well done! You passed the exam';

  @override
  String get examKeepGoing => 'No worries — review the lessons and try again';

  @override
  String get examTryAgain => 'Try again';

  @override
  String examScoreOf(String score, String total) {
    return '$score of $total';
  }

  @override
  String get examStatCorrect => 'Correct';

  @override
  String get examStatWrong => 'Wrong';

  @override
  String get examStatUnanswered => 'Unanswered';

  @override
  String examTimeTaken(String minutes) {
    return 'Time taken: $minutes min';
  }

  @override
  String get examReviewTitle => 'Answer review';

  @override
  String get examYourAnswer => 'Your answer';

  @override
  String get examCorrectAnswer => 'Correct answer';

  @override
  String get examExplanation => 'Explanation';

  @override
  String get examNotAnswered => 'You didn\'t answer this question';

  @override
  String get examShareResult => 'Share result';

  @override
  String examShareText(String percent, String title) {
    return 'I scored $percent on “$title” with Ibn Zaidon Academy 🎓';
  }

  @override
  String get examResultReviewHidden =>
      'The answer review will be available when results are published.';

  @override
  String get myExamsTitle => 'My exams';

  @override
  String get myExamsEmptyTitle => 'You haven\'t taken any exam yet';

  @override
  String get myExamsEmptyBody =>
      'Take your first exam and track your progress here.';

  @override
  String get myExamsGate => 'Sign in to see your exam history.';

  @override
  String examAttemptDate(String date) {
    return 'On $date';
  }

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeGreetingSubtitle => 'What would you like to learn today?';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeFeatured => 'Featured courses';

  @override
  String get homeTrending => 'Trending now';

  @override
  String get homeTopTeachers => 'Top teachers';

  @override
  String get homeQuickExams => 'Exams';

  @override
  String get homeQuickTeachers => 'Teachers';

  @override
  String get homeQuickMyExams => 'My results';

  @override
  String get homeQuickCourses => 'All courses';

  @override
  String get homeStatStudents => 'Students';

  @override
  String get homeStatTeachers => 'Teachers';

  @override
  String get homeStatCourses => 'Courses';

  @override
  String get homeSectionFailed => 'Couldn\'t load this section';

  @override
  String get homeGuestPrompt =>
      'Sign in to see featured courses, teachers and your progress.';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String notificationsBadgeLabel(int count) {
    return '$count unread notifications';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody =>
      'We\'ll let you know here about anything new in your courses and exams.';

  @override
  String get notificationsGate => 'Sign in to see your notifications.';

  @override
  String get notificationPermissionTitle => 'Stay in the loop';

  @override
  String get notificationPermissionBody =>
      'Turn on notifications to get new-lesson alerts, exam results and study reminders.';

  @override
  String get notificationPermissionEnable => 'Enable notifications';

  @override
  String get notificationPermissionLater => 'Not now';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGate =>
      'Sign in to manage your account and track your progress.';

  @override
  String get profileStatCourses => 'Courses';

  @override
  String get profileStatCompleted => 'Completed';

  @override
  String get profileStatExams => 'Exams';

  @override
  String get profileStatLessons => 'Lessons';

  @override
  String get profileStatHours => 'Hours';

  @override
  String get profileStatPassed => 'Passed';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileMyExams => 'My exam history';

  @override
  String get profileExamsCenter => 'Exams center';

  @override
  String get profileTeachers => 'Teachers';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirmTitle => 'Log out?';

  @override
  String get profileLogoutConfirmBody => 'You can sign back in at any time.';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteStep1Title => 'Delete your account?';

  @override
  String get profileDeleteStep1Body =>
      'Your account will be deactivated and you\'ll be signed out on all devices.';

  @override
  String get profileDeleteStep2Title => 'Final confirmation';

  @override
  String get profileDeleteStep2Body =>
      'This can\'t be undone. Are you absolutely sure?';

  @override
  String get profileDeleteConfirm => 'Yes, delete my account';

  @override
  String get profileDeleteFailed =>
      'Couldn\'t delete the account. Please try again.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionLearning => 'Learning';

  @override
  String get profileSectionMore => 'More';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditSaved => 'Changes saved';

  @override
  String get profileFieldNationalId => 'National ID';

  @override
  String get profileFieldGender => 'Gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileFieldBirthDate => 'Date of birth';

  @override
  String get profileFieldNationality => 'Nationality';

  @override
  String get profileAvatarChange => 'Change photo';

  @override
  String get profileAvatarTooLarge => 'The photo must be under 2 MB';

  @override
  String get profileAvatarFromGallery => 'From gallery';

  @override
  String get profileAvatarFromCamera => 'From camera';

  @override
  String get passwordChangeTitle => 'Change password';

  @override
  String get passwordChangeSaved => 'Password changed';

  @override
  String get passwordChangeAction => 'Save password';

  @override
  String get passwordChangeWrongCurrent => 'The current password is incorrect';

  @override
  String get schoolAnnouncements => 'Announcements';

  @override
  String get schoolConduct => 'Code of conduct';

  @override
  String get schoolPlanner => 'Study planner';

  @override
  String get schoolPlannerNotes => 'Daily notes';

  @override
  String get schoolPlannerWeekly => 'Weekly';

  @override
  String get schoolSchedules => 'Schedules';

  @override
  String get schoolScheduleClass => 'Class schedule';

  @override
  String get schoolScheduleExam => 'Exam schedule';

  @override
  String get conductSign => 'I agree & sign';

  @override
  String get conductSigned => 'Code of conduct signed';

  @override
  String get siblingSwitchTitle => 'Switch account';

  @override
  String get siblingSwitchHint => 'Enter the linked account ID';

  @override
  String get siblingSwitchAction => 'Switch';

  @override
  String get siblingSwitched => 'Account switched';

  @override
  String homeGreetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }
}
