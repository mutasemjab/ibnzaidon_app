// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أكاديمية ابن زيدون';

  @override
  String get appTagline => 'تعلّم بذكاء، تميّز بثقة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonPrevious => 'السابق';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonOpen => 'فتح';

  @override
  String get commonDownload => 'تنزيل';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonReset => 'إعادة ضبط';

  @override
  String get commonFilters => 'تصفية';

  @override
  String get commonAll => 'الكل';

  @override
  String get commonFree => 'مجاني';

  @override
  String get commonLoadMoreFailed => 'تعذّر تحميل المزيد';

  @override
  String get commonPullToRefresh => 'اسحب للتحديث';

  @override
  String commonMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String commonHours(int count) {
    return '$count ساعة';
  }

  @override
  String commonCoursesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دورة',
      one: 'دورة واحدة',
      zero: 'لا دورات',
    );
    return '$_temp0';
  }

  @override
  String commonStudentsCount(String count) {
    return '$count طالب';
  }

  @override
  String commonLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دروس',
      one: 'درس واحد',
      zero: 'لا دروس',
    );
    return '$_temp0';
  }

  @override
  String commonQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسئلة',
      one: 'سؤال واحد',
      zero: 'لا أسئلة',
    );
    return '$_temp0';
  }

  @override
  String get errorNoInternet =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.';

  @override
  String get errorTimeout => 'استغرق الاتصال وقتاً طويلاً. حاول مرة أخرى.';

  @override
  String get errorUnauthorized => 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';

  @override
  String get errorForbidden => 'لا تملك صلاحية الوصول إلى هذا المحتوى.';

  @override
  String get errorValidation => 'يرجى التحقق من البيانات المدخلة.';

  @override
  String get errorNotFound => 'لم نعثر على المحتوى المطلوب.';

  @override
  String get errorServer => 'حدث خطأ في الخادم. حاول لاحقاً.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get errorSessionExpired => 'انتهت جلستك. سجّل الدخول مجدداً للمتابعة.';

  @override
  String get errorStateTitle => 'عذراً، حدث خطأ';

  @override
  String get offlineBanner =>
      'أنت غير متصل. تعرض التطبيق آخر البيانات المحفوظة.';

  @override
  String get emptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get emptyMessage => 'جرّب تغيير البحث أو التصفية.';

  @override
  String get gateTitle => 'سجّل الدخول للمتابعة';

  @override
  String get gateMessage =>
      'أنشئ حساباً أو سجّل الدخول للوصول إلى دوراتك واختباراتك وتقدّمك.';

  @override
  String get gateSignIn => 'تسجيل الدخول';

  @override
  String get gateCreateAccount => 'إنشاء حساب';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navMyCourses => 'دوراتي';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get onboardingTitle1 => 'دورات مسجّلة بجودة عالية';

  @override
  String get onboardingBody1 =>
      'شاهد دروسك في أي وقت ومن أي مكان، وتابع من حيث توقفت.';

  @override
  String get onboardingTitle2 => 'اختبارات مع تحليل فوري';

  @override
  String get onboardingBody2 =>
      'اختبر نفسك واعرف نقاط قوتك وضعفك مباشرة بعد التسليم.';

  @override
  String get onboardingTitle3 => 'مكتبة أوراق عمل وامتحانات سابقة';

  @override
  String get onboardingBody3 =>
      'حمّل ملفات PDF وتدرّب على بنوك الأسئلة والامتحانات السابقة.';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get authLoginTitle => 'أهلاً بعودتك';

  @override
  String get authLoginSubtitle => 'سجّل الدخول لمتابعة رحلتك التعليمية';

  @override
  String get authRegisterTitle => 'أنشئ حسابك';

  @override
  String get authRegisterSubtitle => 'انضم إلى أكاديمية ابن زيدون اليوم';

  @override
  String get authFieldName => 'الاسم الكامل';

  @override
  String get authFieldPhone => 'رقم الهاتف';

  @override
  String get authFieldEmail => 'البريد الإلكتروني (اختياري)';

  @override
  String get authFieldPassword => 'كلمة المرور';

  @override
  String get authFieldPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get authFieldCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get authFieldNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authLoginAction => 'تسجيل الدخول';

  @override
  String get authRegisterAction => 'إنشاء الحساب';

  @override
  String get authContinueAsGuest => 'المتابعة كزائر';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationPhone => 'أدخل رقم هاتف صحيحاً';

  @override
  String get validationEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get validationPasswordShort =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authInvalidCredentials => 'رقم الهاتف أو كلمة المرور غير صحيحة';

  @override
  String get authAccountSuspended => 'تم إيقاف هذا الحساب. تواصل مع الإدارة.';

  @override
  String authWelcomeName(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get authWelcomeGuest => 'مرحباً بك';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String examTimeRemaining(String time) {
    return 'الوقت المتبقي $time';
  }

  @override
  String get galleryTitle => 'معرض التصميم';

  @override
  String get galleryButtons => 'الأزرار';

  @override
  String get galleryInputs => 'حقول الإدخال';

  @override
  String get galleryCards => 'البطاقات';

  @override
  String get galleryIndicators => 'المؤشرات';

  @override
  String get galleryStates => 'الحالات';

  @override
  String get galleryOverlays => 'النوافذ المنبثقة';

  @override
  String get galleryNavigation => 'التنقل';

  @override
  String get galleryLoading => 'جاري التحميل';

  @override
  String get galleryShowSheet => 'عرض ورقة سفلية';

  @override
  String get galleryShowDialog => 'عرض نافذة تأكيد';

  @override
  String get galleryShowSnackbar => 'عرض إشعار';

  @override
  String get gallerySampleCourse => 'أساسيات الرياضيات للصف العاشر';

  @override
  String get gallerySampleTeacher => 'أ. سامي الحداد';

  @override
  String get gallerySampleText => 'نص تجريبي';

  @override
  String get gallerySampleMessage => 'هذه رسالة تجريبية لعرض المكوّن';

  @override
  String get exploreTitle => 'استكشف';

  @override
  String get exploreSearchHint => 'ابحث عن دورة...';

  @override
  String get exploreCategories => 'التصنيفات';

  @override
  String get exploreSections => 'الأقسام';

  @override
  String get exploreSubjects => 'المواد';

  @override
  String get exploreViewGrid => 'عرض شبكي';

  @override
  String get exploreViewList => 'عرض قائمة';

  @override
  String get exploreCategoryEmpty => 'لا توجد أقسام أو مواد هنا بعد';

  @override
  String get exploreSearchResults => 'نتائج البحث';

  @override
  String get exploreSearchSignIn => 'سجّل الدخول للبحث في الدورات';

  @override
  String get subjectElective => 'اختيارية';

  @override
  String get subjectCoursesTitle => 'دورات المادة';

  @override
  String get subjectNoCourses => 'لا توجد دورات في هذه المادة بعد';

  @override
  String categorySubcategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أقسام فرعية',
      one: 'قسم فرعي واحد',
      zero: 'لا أقسام فرعية',
    );
    return '$_temp0';
  }

  @override
  String get coursesTitle => 'الدورات';

  @override
  String get coursesEmptyTitle => 'لا توجد دورات مطابقة';

  @override
  String get coursesFiltersTitle => 'تصفية الدورات';

  @override
  String get coursesFilterFeatured => 'مميزة';

  @override
  String get coursesFilterTrending => 'الأكثر رواجاً';

  @override
  String get coursesFilterCategory => 'التصنيف';

  @override
  String get coursesFilterSubject => 'المادة';

  @override
  String get coursesFilterTeacher => 'المدرّس';

  @override
  String coursesFiltersActive(int count) {
    return '$count تصفية مفعّلة';
  }

  @override
  String get coursesSearchHint => 'ابحث في الدورات';

  @override
  String get courseTabContent => 'المحتوى';

  @override
  String get courseTabAbout => 'حول الدورة';

  @override
  String get courseTabReviews => 'التقييمات';

  @override
  String get courseReviewsPlaceholder => 'تقييمات الطلاب ستتوفر قريباً';

  @override
  String get courseWhatYouLearn => 'ماذا ستتعلّم';

  @override
  String get courseRequirements => 'المتطلبات';

  @override
  String get courseDescription => 'وصف الدورة';

  @override
  String get courseNoContent => 'لم يُضف محتوى لهذه الدورة بعد';

  @override
  String get courseTeacher => 'المدرّس';

  @override
  String get courseStudents => 'الطلاب';

  @override
  String get courseDuration => 'المدة';

  @override
  String get courseLevel => 'المستوى';

  @override
  String courseVideos(int count) {
    return '$count فيديو';
  }

  @override
  String coursePdfs(int count) {
    return '$count ملف PDF';
  }

  @override
  String get courseLive => 'مباشر';

  @override
  String get difficultyBeginner => 'مبتدئ';

  @override
  String get difficultyIntermediate => 'متوسط';

  @override
  String get difficultyAdvanced => 'متقدم';

  @override
  String courseUnitExams(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اختبارات',
      one: 'اختبار واحد',
    );
    return '$_temp0';
  }

  @override
  String get courseUnitExamsTitle => 'اختبارات الوحدة';

  @override
  String courseExamMeta(int questions, int minutes) {
    return '$questions أسئلة · $minutes دقيقة';
  }

  @override
  String get lessonFree => 'مجاني';

  @override
  String get lessonLockedTitle => 'الدرس مقفل';

  @override
  String get lessonLockedEnroll => 'فعّل الدورة للوصول إلى هذا الدرس.';

  @override
  String get lessonLockedSequence => 'أكمل الدرس السابق أولاً لفتح هذا الدرس.';

  @override
  String get lessonTypeVideo => 'فيديو';

  @override
  String get lessonTypePdf => 'ملف PDF';

  @override
  String get lessonTypeOther => 'درس';

  @override
  String get courseSequentialHint => 'دروس هذه الدورة تُفتح بالترتيب';

  @override
  String get courseActionStartFree => 'ابدأ التعلّم';

  @override
  String get courseActionContinue => 'متابعة التعلّم';

  @override
  String get courseActionActivate => 'تفعيل ببطاقة';

  @override
  String courseActionBuy(String price) {
    return 'شراء بـ $price';
  }

  @override
  String get courseActionSignIn => 'سجّل الدخول للتسجيل';

  @override
  String courseProgressLabel(String percent) {
    return 'أنجزت $percent';
  }

  @override
  String get activationTitle => 'تفعيل الدورة';

  @override
  String get activationSubtitle => 'أدخل الرمز المطبوع على بطاقتك';

  @override
  String get activationCodeLabel => 'رمز البطاقة';

  @override
  String get activationAction => 'تفعيل';

  @override
  String get activationSuccessTitle => 'تم تفعيل الدورة!';

  @override
  String activationSuccessBody(String name) {
    return 'يمكنك الآن الوصول إلى «$name».';
  }

  @override
  String get activationStart => 'ابدأ الآن';

  @override
  String get activationFailed =>
      'تعذّر تفعيل البطاقة. تأكد من الرمز وحاول مجدداً.';

  @override
  String get purchaseVerifying => 'جارٍ تأكيد عملية الشراء…';

  @override
  String get purchaseSuccess => 'تم شراء الدورة بنجاح';

  @override
  String get purchasePending => 'عملية الشراء بانتظار الموافقة';

  @override
  String get purchaseCancelled => 'تم إلغاء عملية الشراء';

  @override
  String get purchaseFailed => 'تعذّر إتمام عملية الشراء';

  @override
  String get purchaseVerifyFailed =>
      'تم الدفع لكن تعذّر تأكيده. أعد المحاولة ولن يُخصم منك مجدداً.';

  @override
  String get purchaseRestore => 'استعادة المشتريات';

  @override
  String get myCoursesTitle => 'دوراتي';

  @override
  String get myCoursesEmptyTitle => 'لم تسجّل في أي دورة بعد';

  @override
  String get myCoursesEmptyBody => 'تصفّح الدورات وفعّل بطاقتك لتبدأ.';

  @override
  String get myCoursesBrowse => 'تصفّح الدورات';

  @override
  String get myCoursesCompleted => 'مكتملة';

  @override
  String get myCoursesContinue => 'متابعة';

  @override
  String get myCoursesGate => 'سجّل الدخول لعرض دوراتك وتقدّمك.';

  @override
  String get teachersTitle => 'المدرّسون';

  @override
  String get teachersSearchHint => 'ابحث عن مدرّس';

  @override
  String get teachersEmpty => 'لا يوجد مدرّسون مطابقون';

  @override
  String get teacherVerified => 'مدرّس موثّق';

  @override
  String teacherExperience(int years) {
    return '$years سنوات خبرة';
  }

  @override
  String get teacherQualification => 'المؤهل العلمي';

  @override
  String get teacherAbout => 'نبذة عن المدرّس';

  @override
  String get teacherCoursesTitle => 'دورات المدرّس';

  @override
  String get teacherNoCourses => 'لا توجد دورات لهذا المدرّس بعد';

  @override
  String get libraryTitle => 'المكتبة';

  @override
  String get libraryPreviousExams => 'امتحانات سابقة';

  @override
  String get libraryQuestionBanks => 'بنوك الأسئلة';

  @override
  String get libraryWorksheets => 'أوراق العمل';

  @override
  String get librarySearchHint => 'ابحث في الملفات';

  @override
  String get libraryYear => 'السنة';

  @override
  String get librarySubject => 'المادة';

  @override
  String get libraryEmptyTitle => 'لا توجد ملفات';

  @override
  String libraryPages(int count) {
    return '$count صفحة';
  }

  @override
  String get libraryOpen => 'فتح';

  @override
  String libraryDownloading(String percent) {
    return 'جارٍ التنزيل $percent';
  }

  @override
  String get libraryDownloaded => 'محفوظ للقراءة دون اتصال';

  @override
  String get libraryDownloadFailed => 'تعذّر تنزيل الملف';

  @override
  String get libraryShareFile => 'مشاركة الملف';

  @override
  String get pdfViewerFailed => 'تعذّر عرض الملف';

  @override
  String pdfPageOf(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String get lessonPrevious => 'الدرس السابق';

  @override
  String get lessonNext => 'الدرس التالي';

  @override
  String get lessonMarkComplete => 'تحديد كمكتمل';

  @override
  String get lessonCompleted => 'تم إكمال الدرس';

  @override
  String get lessonResumeFrom => 'سنكمل من حيث توقفت';

  @override
  String get lessonNoVideo => 'لا يتوفر فيديو لهذا الدرس';

  @override
  String get lessonNoFile => 'لا يتوفر ملف لهذا الدرس';

  @override
  String get lessonOpenFile => 'فتح الملف';

  @override
  String get lessonForbiddenTitle => 'لا يمكنك فتح هذا الدرس بعد';

  @override
  String get lessonForbiddenFallback =>
      'فعّل الدورة أو أكمل الدروس السابقة للمتابعة.';

  @override
  String get lessonBackToCourse => 'العودة إلى الدورة';

  @override
  String lessonCoursePercent(String percent) {
    return 'تقدّم الدورة $percent';
  }

  @override
  String get examsTitle => 'الاختبارات';

  @override
  String get examsSearchHint => 'ابحث في الاختبارات';

  @override
  String get examsEmptyTitle => 'لا توجد اختبارات';

  @override
  String get examsQuickAccess => 'الاختبارات';

  @override
  String get examDetailTitle => 'تفاصيل الاختبار';

  @override
  String examDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String examTotalMarks(String marks) {
    return '$marks درجة';
  }

  @override
  String examPassMarks(String marks) {
    return 'درجة النجاح $marks';
  }

  @override
  String get examInstructions => 'التعليمات';

  @override
  String get examRulesTitle => 'قبل أن تبدأ';

  @override
  String get examRuleTimer => 'يبدأ العدّ التنازلي فور بدء الاختبار ولا يتوقف.';

  @override
  String get examRuleAutosave =>
      'تُحفظ إجاباتك تلقائياً ويمكنك المتابعة إن أُغلق التطبيق.';

  @override
  String get examRuleAutoSubmit =>
      'يُسلَّم الاختبار تلقائياً عند انتهاء الوقت.';

  @override
  String get examStart => 'ابدأ الاختبار';

  @override
  String get examResume => 'متابعة الاختبار';

  @override
  String get examStartConfirmTitle => 'بدء الاختبار؟';

  @override
  String examStartConfirmBody(int minutes) {
    return 'مدة الاختبار $minutes دقيقة وسيبدأ العدّ فوراً.';
  }

  @override
  String get examSignInToStart => 'سجّل الدخول لبدء الاختبار';

  @override
  String examQuestionOf(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String examMarksLabel(String marks) {
    return '$marks درجة';
  }

  @override
  String get examNavigator => 'قائمة الأسئلة';

  @override
  String get examLegendAnswered => 'مُجاب';

  @override
  String get examLegendUnanswered => 'غير مُجاب';

  @override
  String get examLegendFlagged => 'للمراجعة';

  @override
  String get examFlag => 'تأشير للمراجعة';

  @override
  String get examUnflag => 'إزالة التأشير';

  @override
  String get examClearAnswer => 'مسح الإجابة';

  @override
  String get examSubmit => 'تسليم الاختبار';

  @override
  String get examSubmitConfirmTitle => 'تسليم الاختبار؟';

  @override
  String examSubmitConfirmUnanswered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسئلة',
      one: 'سؤال واحد',
    );
    return 'لديك $_temp0 بدون إجابة. هل تريد التسليم؟';
  }

  @override
  String get examSubmitConfirmAll => 'أجبت عن كل الأسئلة. هل تريد التسليم؟';

  @override
  String get examLeaveTitle => 'مغادرة الاختبار؟';

  @override
  String get examLeaveBody =>
      'يستمر الوقت بالعدّ وتُحفظ إجاباتك. يمكنك العودة لمتابعة الاختبار.';

  @override
  String get examLeaveConfirm => 'مغادرة';

  @override
  String get examTimeUpTitle => 'انتهى الوقت';

  @override
  String get examTimeUpBody => 'جارٍ تسليم إجاباتك تلقائياً…';

  @override
  String get examSubmitFailed =>
      'تعذّر تسليم الاختبار. إجاباتك محفوظة، أعد المحاولة.';

  @override
  String get examSubmitting => 'جارٍ التسليم…';

  @override
  String get examNoQuestions => 'لا توجد أسئلة في هذا الاختبار';

  @override
  String get examResultTitle => 'نتيجة الاختبار';

  @override
  String get examPassed => 'ناجح';

  @override
  String get examFailed => 'لم تجتز الاختبار';

  @override
  String get examCongrats => 'أحسنت! لقد اجتزت الاختبار';

  @override
  String get examKeepGoing => 'لا بأس، راجع الدروس وحاول مجدداً';

  @override
  String get examTryAgain => 'حاول مجدداً';

  @override
  String examScoreOf(String score, String total) {
    return '$score من $total';
  }

  @override
  String get examStatCorrect => 'صحيحة';

  @override
  String get examStatWrong => 'خاطئة';

  @override
  String get examStatUnanswered => 'بدون إجابة';

  @override
  String examTimeTaken(String minutes) {
    return 'الوقت المستغرق: $minutes دقيقة';
  }

  @override
  String get examReviewTitle => 'مراجعة الإجابات';

  @override
  String get examYourAnswer => 'إجابتك';

  @override
  String get examCorrectAnswer => 'الإجابة الصحيحة';

  @override
  String get examExplanation => 'الشرح';

  @override
  String get examNotAnswered => 'لم تجب عن هذا السؤال';

  @override
  String get examShareResult => 'مشاركة النتيجة';

  @override
  String examShareText(String percent, String title) {
    return 'حصلت على $percent في اختبار «$title» عبر أكاديمية ابن زيدون 🎓';
  }

  @override
  String get examResultReviewHidden => 'ستظهر مراجعة الإجابات عند نشر النتائج.';

  @override
  String get myExamsTitle => 'اختباراتي';

  @override
  String get myExamsEmptyTitle => 'لم تخض أي اختبار بعد';

  @override
  String get myExamsEmptyBody => 'ابدأ أول اختبار لك وتابع تقدّمك هنا.';

  @override
  String get myExamsGate => 'سجّل الدخول لعرض سجل اختباراتك.';

  @override
  String examAttemptDate(String date) {
    return 'بتاريخ $date';
  }

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeGreetingSubtitle => 'ماذا تريد أن تتعلم اليوم؟';

  @override
  String get homeCategories => 'التصنيفات';

  @override
  String get homeFeatured => 'دورات مميزة';

  @override
  String get homeTrending => 'الأكثر رواجاً';

  @override
  String get homeTopTeachers => 'أفضل المدرّسين';

  @override
  String get homeQuickExams => 'الاختبارات';

  @override
  String get homeQuickTeachers => 'المدرّسون';

  @override
  String get homeQuickMyExams => 'نتائجي';

  @override
  String get homeQuickCourses => 'كل الدورات';

  @override
  String get homeStatStudents => 'طالب';

  @override
  String get homeStatTeachers => 'مدرّس';

  @override
  String get homeStatCourses => 'دورة';

  @override
  String get homeSectionFailed => 'تعذّر تحميل هذا القسم';

  @override
  String get homeGuestPrompt =>
      'سجّل الدخول لرؤية الدورات المميزة والمدرّسين وتقدّمك.';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String notificationsBadgeLabel(int count) {
    return '$count إشعارات غير مقروءة';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyBody =>
      'سنعلمك هنا بكل جديد في دوراتك واختباراتك.';

  @override
  String get notificationsGate => 'سجّل الدخول لعرض إشعاراتك.';

  @override
  String get notificationPermissionTitle => 'ابقَ على اطّلاع';

  @override
  String get notificationPermissionBody =>
      'فعّل الإشعارات لتصلك تنبيهات الدروس الجديدة ونتائج الاختبارات وتذكيرات الدراسة.';

  @override
  String get notificationPermissionEnable => 'تفعيل الإشعارات';

  @override
  String get notificationPermissionLater => 'ليس الآن';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get profileGate => 'سجّل الدخول لإدارة حسابك وتتبّع تقدّمك.';

  @override
  String get profileStatCourses => 'دورات';

  @override
  String get profileStatCompleted => 'مكتملة';

  @override
  String get profileStatExams => 'اختبارات';

  @override
  String get profileStatLessons => 'دروس';

  @override
  String get profileStatHours => 'ساعات';

  @override
  String get profileStatPassed => 'ناجح';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileMyExams => 'سجل اختباراتي';

  @override
  String get profileExamsCenter => 'مركز الاختبارات';

  @override
  String get profileTeachers => 'المدرّسون';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get profileLogoutConfirmBody => 'يمكنك تسجيل الدخول مجدداً في أي وقت.';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteStep1Title => 'حذف حسابك؟';

  @override
  String get profileDeleteStep1Body =>
      'سيتم تعطيل حسابك وتسجيل خروجك من جميع الأجهزة.';

  @override
  String get profileDeleteStep2Title => 'تأكيد نهائي';

  @override
  String get profileDeleteStep2Body =>
      'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد تماماً؟';

  @override
  String get profileDeleteConfirm => 'نعم، احذف حسابي';

  @override
  String get profileDeleteFailed => 'تعذّر حذف الحساب. حاول مجدداً.';

  @override
  String get profileSectionAccount => 'الحساب';

  @override
  String get profileSectionLearning => 'التعلّم';

  @override
  String get profileSectionMore => 'المزيد';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileEditSaved => 'تم حفظ التغييرات';

  @override
  String get profileFieldNationalId => 'الرقم الوطني';

  @override
  String get profileFieldGender => 'الجنس';

  @override
  String get profileGenderMale => 'ذكر';

  @override
  String get profileGenderFemale => 'أنثى';

  @override
  String get profileFieldBirthDate => 'تاريخ الميلاد';

  @override
  String get profileFieldNationality => 'الجنسية';

  @override
  String get profileAvatarChange => 'تغيير الصورة';

  @override
  String get profileAvatarTooLarge => 'حجم الصورة يجب ألا يتجاوز 2 ميغابايت';

  @override
  String get profileAvatarFromGallery => 'من المعرض';

  @override
  String get profileAvatarFromCamera => 'من الكاميرا';

  @override
  String get passwordChangeTitle => 'تغيير كلمة المرور';

  @override
  String get passwordChangeSaved => 'تم تغيير كلمة المرور';

  @override
  String get passwordChangeAction => 'حفظ كلمة المرور';

  @override
  String get passwordChangeWrongCurrent => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get schoolAnnouncements => 'الإعلانات';

  @override
  String get schoolConduct => 'ميثاق السلوك';

  @override
  String get schoolPlanner => 'المخطط الدراسي';

  @override
  String get schoolPlannerNotes => 'ملاحظات اليوم';

  @override
  String get schoolPlannerWeekly => 'الأسبوع';

  @override
  String get schoolSchedules => 'الجداول';

  @override
  String get schoolScheduleClass => 'جدول الحصص';

  @override
  String get schoolScheduleExam => 'جدول الاختبارات';

  @override
  String get conductSign => 'أوافق وأوقّع';

  @override
  String get conductSigned => 'تم توقيع الميثاق';

  @override
  String get siblingSwitchTitle => 'تبديل الحساب';

  @override
  String get siblingSwitchHint => 'أدخل رقم الحساب المرتبط';

  @override
  String get siblingSwitchAction => 'تبديل';

  @override
  String get siblingSwitched => 'تم تبديل الحساب';

  @override
  String homeGreetingWithName(String greeting, String name) {
    return '$greeting، $name';
  }
}
