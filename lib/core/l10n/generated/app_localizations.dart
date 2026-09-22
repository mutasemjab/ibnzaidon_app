import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'أكاديمية ابن زيدون'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'تعلّم بذكاء، تميّز بثقة'**
  String get appTagline;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonOk.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get commonOk;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get commonSeeAll;

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get commonNext;

  /// No description provided for @commonPrevious.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get commonPrevious;

  /// No description provided for @commonSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get commonSkip;

  /// No description provided for @commonContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

  /// No description provided for @commonOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get commonOpen;

  /// No description provided for @commonDownload.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get commonDownload;

  /// No description provided for @commonApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get commonApply;

  /// No description provided for @commonReset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط'**
  String get commonReset;

  /// No description provided for @commonFilters.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get commonFilters;

  /// No description provided for @commonAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get commonAll;

  /// No description provided for @commonFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get commonFree;

  /// No description provided for @commonLoadMoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المزيد'**
  String get commonLoadMoreFailed;

  /// No description provided for @commonPullToRefresh.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للتحديث'**
  String get commonPullToRefresh;

  /// No description provided for @commonMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String commonMinutes(int count);

  /// No description provided for @commonHours.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعة'**
  String commonHours(int count);

  /// No description provided for @commonCoursesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا دورات} =1{دورة واحدة} other{{count} دورة}}'**
  String commonCoursesCount(int count);

  /// No description provided for @commonStudentsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String commonStudentsCount(String count);

  /// No description provided for @commonLessonsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا دروس} =1{درس واحد} other{{count} دروس}}'**
  String commonLessonsCount(int count);

  /// No description provided for @commonQuestionsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا أسئلة} =1{سؤال واحد} other{{count} أسئلة}}'**
  String commonQuestionsCount(int count);

  /// No description provided for @errorNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.'**
  String get errorNoInternet;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الاتصال وقتاً طويلاً. حاول مرة أخرى.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية الوصول إلى هذا المحتوى.'**
  String get errorForbidden;

  /// No description provided for @errorValidation.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من البيانات المدخلة.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على المحتوى المطلوب.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الخادم. حاول لاحقاً.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع.'**
  String get errorUnknown;

  /// No description provided for @errorSessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. سجّل الدخول مجدداً للمتابعة.'**
  String get errorSessionExpired;

  /// No description provided for @errorStateTitle.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، حدث خطأ'**
  String get errorStateTitle;

  /// No description provided for @offlineBanner.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل. تعرض التطبيق آخر البيانات المحفوظة.'**
  String get offlineBanner;

  /// No description provided for @emptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب تغيير البحث أو التصفية.'**
  String get emptyMessage;

  /// No description provided for @gateTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للمتابعة'**
  String get gateTitle;

  /// No description provided for @gateMessage.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً أو سجّل الدخول للوصول إلى دوراتك واختباراتك وتقدّمك.'**
  String get gateMessage;

  /// No description provided for @gateSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get gateSignIn;

  /// No description provided for @gateCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get gateCreateAccount;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In ar, this message translates to:
  /// **'استكشاف'**
  String get navExplore;

  /// No description provided for @navMyCourses.
  ///
  /// In ar, this message translates to:
  /// **'دوراتي'**
  String get navMyCourses;

  /// No description provided for @navLibrary.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة'**
  String get navLibrary;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'دورات مسجّلة بجودة عالية'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In ar, this message translates to:
  /// **'شاهد دروسك في أي وقت ومن أي مكان، وتابع من حيث توقفت.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات مع تحليل فوري'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In ar, this message translates to:
  /// **'اختبر نفسك واعرف نقاط قوتك وضعفك مباشرة بعد التسليم.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة أوراق عمل وامتحانات سابقة'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In ar, this message translates to:
  /// **'حمّل ملفات PDF وتدرّب على بنوك الأسئلة والامتحانات السابقة.'**
  String get onboardingBody3;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingGetStarted;

  /// No description provided for @authLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لمتابعة رحلتك التعليمية'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى أكاديمية ابن زيدون اليوم'**
  String get authRegisterSubtitle;

  /// No description provided for @authFieldName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get authFieldName;

  /// No description provided for @authFieldPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get authFieldPhone;

  /// No description provided for @authFieldEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني (اختياري)'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authFieldPassword;

  /// No description provided for @authFieldPasswordConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authFieldPasswordConfirm;

  /// No description provided for @authFieldCurrentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get authFieldCurrentPassword;

  /// No description provided for @authFieldNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get authFieldNewPassword;

  /// No description provided for @authLoginAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLoginAction;

  /// No description provided for @authRegisterAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get authRegisterAction;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة كزائر'**
  String get authContinueAsGuest;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authHaveAccount;

  /// No description provided for @authShowPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get authHidePassword;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationRequired;

  /// No description provided for @validationPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيحاً'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريداً إلكترونياً صحيحاً'**
  String get validationEmail;

  /// No description provided for @validationPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get validationPasswordShort;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validationPasswordMismatch;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة'**
  String get authInvalidCredentials;

  /// No description provided for @authAccountSuspended.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف هذا الحساب. تواصل مع الإدارة.'**
  String get authAccountSuspended;

  /// No description provided for @authWelcomeName.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String authWelcomeName(String name);

  /// No description provided for @authWelcomeGuest.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get authWelcomeGuest;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsThemeDark;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String settingsVersion(String version);

  /// No description provided for @examTimeRemaining.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي {time}'**
  String examTimeRemaining(String time);

  /// No description provided for @galleryTitle.
  ///
  /// In ar, this message translates to:
  /// **'معرض التصميم'**
  String get galleryTitle;

  /// No description provided for @galleryButtons.
  ///
  /// In ar, this message translates to:
  /// **'الأزرار'**
  String get galleryButtons;

  /// No description provided for @galleryInputs.
  ///
  /// In ar, this message translates to:
  /// **'حقول الإدخال'**
  String get galleryInputs;

  /// No description provided for @galleryCards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات'**
  String get galleryCards;

  /// No description provided for @galleryIndicators.
  ///
  /// In ar, this message translates to:
  /// **'المؤشرات'**
  String get galleryIndicators;

  /// No description provided for @galleryStates.
  ///
  /// In ar, this message translates to:
  /// **'الحالات'**
  String get galleryStates;

  /// No description provided for @galleryOverlays.
  ///
  /// In ar, this message translates to:
  /// **'النوافذ المنبثقة'**
  String get galleryOverlays;

  /// No description provided for @galleryNavigation.
  ///
  /// In ar, this message translates to:
  /// **'التنقل'**
  String get galleryNavigation;

  /// No description provided for @galleryLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get galleryLoading;

  /// No description provided for @galleryShowSheet.
  ///
  /// In ar, this message translates to:
  /// **'عرض ورقة سفلية'**
  String get galleryShowSheet;

  /// No description provided for @galleryShowDialog.
  ///
  /// In ar, this message translates to:
  /// **'عرض نافذة تأكيد'**
  String get galleryShowDialog;

  /// No description provided for @galleryShowSnackbar.
  ///
  /// In ar, this message translates to:
  /// **'عرض إشعار'**
  String get galleryShowSnackbar;

  /// No description provided for @gallerySampleCourse.
  ///
  /// In ar, this message translates to:
  /// **'أساسيات الرياضيات للصف العاشر'**
  String get gallerySampleCourse;

  /// No description provided for @gallerySampleTeacher.
  ///
  /// In ar, this message translates to:
  /// **'أ. سامي الحداد'**
  String get gallerySampleTeacher;

  /// No description provided for @gallerySampleText.
  ///
  /// In ar, this message translates to:
  /// **'نص تجريبي'**
  String get gallerySampleText;

  /// No description provided for @gallerySampleMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذه رسالة تجريبية لعرض المكوّن'**
  String get gallerySampleMessage;

  /// No description provided for @exploreTitle.
  ///
  /// In ar, this message translates to:
  /// **'استكشف'**
  String get exploreTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دورة...'**
  String get exploreSearchHint;

  /// No description provided for @exploreCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get exploreCategories;

  /// No description provided for @exploreSections.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get exploreSections;

  /// No description provided for @exploreSubjects.
  ///
  /// In ar, this message translates to:
  /// **'المواد'**
  String get exploreSubjects;

  /// No description provided for @exploreViewGrid.
  ///
  /// In ar, this message translates to:
  /// **'عرض شبكي'**
  String get exploreViewGrid;

  /// No description provided for @exploreViewList.
  ///
  /// In ar, this message translates to:
  /// **'عرض قائمة'**
  String get exploreViewList;

  /// No description provided for @exploreCategoryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أقسام أو مواد هنا بعد'**
  String get exploreCategoryEmpty;

  /// No description provided for @exploreSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث'**
  String get exploreSearchResults;

  /// No description provided for @exploreSearchSignIn.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للبحث في الدورات'**
  String get exploreSearchSignIn;

  /// No description provided for @subjectElective.
  ///
  /// In ar, this message translates to:
  /// **'اختيارية'**
  String get subjectElective;

  /// No description provided for @subjectCoursesTitle.
  ///
  /// In ar, this message translates to:
  /// **'دورات المادة'**
  String get subjectCoursesTitle;

  /// No description provided for @subjectNoCourses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات في هذه المادة بعد'**
  String get subjectNoCourses;

  /// No description provided for @categorySubcategories.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا أقسام فرعية} =1{قسم فرعي واحد} other{{count} أقسام فرعية}}'**
  String categorySubcategories(int count);

  /// No description provided for @coursesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدورات'**
  String get coursesTitle;

  /// No description provided for @coursesEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات مطابقة'**
  String get coursesEmptyTitle;

  /// No description provided for @coursesFiltersTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفية الدورات'**
  String get coursesFiltersTitle;

  /// No description provided for @coursesFilterFeatured.
  ///
  /// In ar, this message translates to:
  /// **'مميزة'**
  String get coursesFilterFeatured;

  /// No description provided for @coursesFilterTrending.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر رواجاً'**
  String get coursesFilterTrending;

  /// No description provided for @coursesFilterCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get coursesFilterCategory;

  /// No description provided for @coursesFilterSubject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get coursesFilterSubject;

  /// No description provided for @coursesFilterTeacher.
  ///
  /// In ar, this message translates to:
  /// **'المدرّس'**
  String get coursesFilterTeacher;

  /// No description provided for @coursesFiltersActive.
  ///
  /// In ar, this message translates to:
  /// **'{count} تصفية مفعّلة'**
  String coursesFiltersActive(int count);

  /// No description provided for @coursesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الدورات'**
  String get coursesSearchHint;

  /// No description provided for @courseTabContent.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى'**
  String get courseTabContent;

  /// No description provided for @courseTabAbout.
  ///
  /// In ar, this message translates to:
  /// **'حول الدورة'**
  String get courseTabAbout;

  /// No description provided for @courseTabReviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get courseTabReviews;

  /// No description provided for @courseReviewsPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'تقييمات الطلاب ستتوفر قريباً'**
  String get courseReviewsPlaceholder;

  /// No description provided for @courseWhatYouLearn.
  ///
  /// In ar, this message translates to:
  /// **'ماذا ستتعلّم'**
  String get courseWhatYouLearn;

  /// No description provided for @courseRequirements.
  ///
  /// In ar, this message translates to:
  /// **'المتطلبات'**
  String get courseRequirements;

  /// No description provided for @courseDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف الدورة'**
  String get courseDescription;

  /// No description provided for @courseNoContent.
  ///
  /// In ar, this message translates to:
  /// **'لم يُضف محتوى لهذه الدورة بعد'**
  String get courseNoContent;

  /// No description provided for @courseTeacher.
  ///
  /// In ar, this message translates to:
  /// **'المدرّس'**
  String get courseTeacher;

  /// No description provided for @courseStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get courseStudents;

  /// No description provided for @courseDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get courseDuration;

  /// No description provided for @courseLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى'**
  String get courseLevel;

  /// No description provided for @courseVideos.
  ///
  /// In ar, this message translates to:
  /// **'{count} فيديو'**
  String courseVideos(int count);

  /// No description provided for @coursePdfs.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملف PDF'**
  String coursePdfs(int count);

  /// No description provided for @courseLive.
  ///
  /// In ar, this message translates to:
  /// **'مباشر'**
  String get courseLive;

  /// No description provided for @difficultyBeginner.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ'**
  String get difficultyBeginner;

  /// No description provided for @difficultyIntermediate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get difficultyIntermediate;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'متقدم'**
  String get difficultyAdvanced;

  /// No description provided for @courseUnitExams.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{اختبار واحد} other{{count} اختبارات}}'**
  String courseUnitExams(int count);

  /// No description provided for @courseUnitExamsTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات الوحدة'**
  String get courseUnitExamsTitle;

  /// No description provided for @courseExamMeta.
  ///
  /// In ar, this message translates to:
  /// **'{questions} أسئلة · {minutes} دقيقة'**
  String courseExamMeta(int questions, int minutes);

  /// No description provided for @lessonFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get lessonFree;

  /// No description provided for @lessonLockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدرس مقفل'**
  String get lessonLockedTitle;

  /// No description provided for @lessonLockedEnroll.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الدورة للوصول إلى هذا الدرس.'**
  String get lessonLockedEnroll;

  /// No description provided for @lessonLockedSequence.
  ///
  /// In ar, this message translates to:
  /// **'أكمل الدرس السابق أولاً لفتح هذا الدرس.'**
  String get lessonLockedSequence;

  /// No description provided for @lessonTypeVideo.
  ///
  /// In ar, this message translates to:
  /// **'فيديو'**
  String get lessonTypeVideo;

  /// No description provided for @lessonTypePdf.
  ///
  /// In ar, this message translates to:
  /// **'ملف PDF'**
  String get lessonTypePdf;

  /// No description provided for @lessonTypeOther.
  ///
  /// In ar, this message translates to:
  /// **'درس'**
  String get lessonTypeOther;

  /// No description provided for @courseSequentialHint.
  ///
  /// In ar, this message translates to:
  /// **'دروس هذه الدورة تُفتح بالترتيب'**
  String get courseSequentialHint;

  /// No description provided for @courseActionStartFree.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التعلّم'**
  String get courseActionStartFree;

  /// No description provided for @courseActionContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعلّم'**
  String get courseActionContinue;

  /// No description provided for @courseActionActivate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل ببطاقة'**
  String get courseActionActivate;

  /// No description provided for @courseActionBuy.
  ///
  /// In ar, this message translates to:
  /// **'شراء بـ {price}'**
  String courseActionBuy(String price);

  /// No description provided for @courseActionSignIn.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للتسجيل'**
  String get courseActionSignIn;

  /// No description provided for @courseProgressLabel.
  ///
  /// In ar, this message translates to:
  /// **'أنجزت {percent}'**
  String courseProgressLabel(String percent);

  /// No description provided for @activationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الدورة'**
  String get activationTitle;

  /// No description provided for @activationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المطبوع على بطاقتك'**
  String get activationSubtitle;

  /// No description provided for @activationCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز البطاقة'**
  String get activationCodeLabel;

  /// No description provided for @activationAction.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activationAction;

  /// No description provided for @activationSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الدورة!'**
  String get activationSuccessTitle;

  /// No description provided for @activationSuccessBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الآن الوصول إلى «{name}».'**
  String activationSuccessBody(String name);

  /// No description provided for @activationStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get activationStart;

  /// No description provided for @activationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تفعيل البطاقة. تأكد من الرمز وحاول مجدداً.'**
  String get activationFailed;

  /// No description provided for @purchaseVerifying.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تأكيد عملية الشراء…'**
  String get purchaseVerifying;

  /// No description provided for @purchaseSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم شراء الدورة بنجاح'**
  String get purchaseSuccess;

  /// No description provided for @purchasePending.
  ///
  /// In ar, this message translates to:
  /// **'عملية الشراء بانتظار الموافقة'**
  String get purchasePending;

  /// No description provided for @purchaseCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء عملية الشراء'**
  String get purchaseCancelled;

  /// No description provided for @purchaseFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إتمام عملية الشراء'**
  String get purchaseFailed;

  /// No description provided for @purchaseVerifyFailed.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع لكن تعذّر تأكيده. أعد المحاولة ولن يُخصم منك مجدداً.'**
  String get purchaseVerifyFailed;

  /// No description provided for @purchaseRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المشتريات'**
  String get purchaseRestore;

  /// No description provided for @myCoursesTitle.
  ///
  /// In ar, this message translates to:
  /// **'دوراتي'**
  String get myCoursesTitle;

  /// No description provided for @myCoursesEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم تسجّل في أي دورة بعد'**
  String get myCoursesEmptyTitle;

  /// No description provided for @myCoursesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الدورات وفعّل بطاقتك لتبدأ.'**
  String get myCoursesEmptyBody;

  /// No description provided for @myCoursesBrowse.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الدورات'**
  String get myCoursesBrowse;

  /// No description provided for @myCoursesCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get myCoursesCompleted;

  /// No description provided for @myCoursesContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get myCoursesContinue;

  /// No description provided for @myCoursesGate.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لعرض دوراتك وتقدّمك.'**
  String get myCoursesGate;

  /// No description provided for @teachersTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدرّسون'**
  String get teachersTitle;

  /// No description provided for @teachersSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مدرّس'**
  String get teachersSearchHint;

  /// No description provided for @teachersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مدرّسون مطابقون'**
  String get teachersEmpty;

  /// No description provided for @teacherVerified.
  ///
  /// In ar, this message translates to:
  /// **'مدرّس موثّق'**
  String get teacherVerified;

  /// No description provided for @teacherExperience.
  ///
  /// In ar, this message translates to:
  /// **'{years} سنوات خبرة'**
  String teacherExperience(int years);

  /// No description provided for @teacherQualification.
  ///
  /// In ar, this message translates to:
  /// **'المؤهل العلمي'**
  String get teacherQualification;

  /// No description provided for @teacherAbout.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن المدرّس'**
  String get teacherAbout;

  /// No description provided for @teacherCoursesTitle.
  ///
  /// In ar, this message translates to:
  /// **'دورات المدرّس'**
  String get teacherCoursesTitle;

  /// No description provided for @teacherNoCourses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات لهذا المدرّس بعد'**
  String get teacherNoCourses;

  /// No description provided for @libraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة'**
  String get libraryTitle;

  /// No description provided for @libraryPreviousExams.
  ///
  /// In ar, this message translates to:
  /// **'امتحانات سابقة'**
  String get libraryPreviousExams;

  /// No description provided for @libraryQuestionBanks.
  ///
  /// In ar, this message translates to:
  /// **'بنوك الأسئلة'**
  String get libraryQuestionBanks;

  /// No description provided for @libraryWorksheets.
  ///
  /// In ar, this message translates to:
  /// **'أوراق العمل'**
  String get libraryWorksheets;

  /// No description provided for @librarySearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الملفات'**
  String get librarySearchHint;

  /// No description provided for @libraryYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get libraryYear;

  /// No description provided for @librarySubject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get librarySubject;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملفات'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryPages.
  ///
  /// In ar, this message translates to:
  /// **'{count} صفحة'**
  String libraryPages(int count);

  /// No description provided for @libraryOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get libraryOpen;

  /// No description provided for @libraryDownloading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التنزيل {percent}'**
  String libraryDownloading(String percent);

  /// No description provided for @libraryDownloaded.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ للقراءة دون اتصال'**
  String get libraryDownloaded;

  /// No description provided for @libraryDownloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تنزيل الملف'**
  String get libraryDownloadFailed;

  /// No description provided for @libraryShareFile.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الملف'**
  String get libraryShareFile;

  /// No description provided for @pdfViewerFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر عرض الملف'**
  String get pdfViewerFailed;

  /// No description provided for @pdfPageOf.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {current} من {total}'**
  String pdfPageOf(int current, int total);

  /// No description provided for @lessonPrevious.
  ///
  /// In ar, this message translates to:
  /// **'الدرس السابق'**
  String get lessonPrevious;

  /// No description provided for @lessonNext.
  ///
  /// In ar, this message translates to:
  /// **'الدرس التالي'**
  String get lessonNext;

  /// No description provided for @lessonMarkComplete.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمكتمل'**
  String get lessonMarkComplete;

  /// No description provided for @lessonCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال الدرس'**
  String get lessonCompleted;

  /// No description provided for @lessonResumeFrom.
  ///
  /// In ar, this message translates to:
  /// **'سنكمل من حيث توقفت'**
  String get lessonResumeFrom;

  /// No description provided for @lessonNoVideo.
  ///
  /// In ar, this message translates to:
  /// **'لا يتوفر فيديو لهذا الدرس'**
  String get lessonNoVideo;

  /// No description provided for @lessonNoFile.
  ///
  /// In ar, this message translates to:
  /// **'لا يتوفر ملف لهذا الدرس'**
  String get lessonNoFile;

  /// No description provided for @lessonOpenFile.
  ///
  /// In ar, this message translates to:
  /// **'فتح الملف'**
  String get lessonOpenFile;

  /// No description provided for @lessonForbiddenTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك فتح هذا الدرس بعد'**
  String get lessonForbiddenTitle;

  /// No description provided for @lessonForbiddenFallback.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الدورة أو أكمل الدروس السابقة للمتابعة.'**
  String get lessonForbiddenFallback;

  /// No description provided for @lessonBackToCourse.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الدورة'**
  String get lessonBackToCourse;

  /// No description provided for @lessonCoursePercent.
  ///
  /// In ar, this message translates to:
  /// **'تقدّم الدورة {percent}'**
  String lessonCoursePercent(String percent);

  /// No description provided for @examsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get examsTitle;

  /// No description provided for @examsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الاختبارات'**
  String get examsSearchHint;

  /// No description provided for @examsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اختبارات'**
  String get examsEmptyTitle;

  /// No description provided for @examsQuickAccess.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get examsQuickAccess;

  /// No description provided for @examDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الاختبار'**
  String get examDetailTitle;

  /// No description provided for @examDurationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String examDurationMinutes(int minutes);

  /// No description provided for @examTotalMarks.
  ///
  /// In ar, this message translates to:
  /// **'{marks} درجة'**
  String examTotalMarks(String marks);

  /// No description provided for @examPassMarks.
  ///
  /// In ar, this message translates to:
  /// **'درجة النجاح {marks}'**
  String examPassMarks(String marks);

  /// No description provided for @examInstructions.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات'**
  String get examInstructions;

  /// No description provided for @examRulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'قبل أن تبدأ'**
  String get examRulesTitle;

  /// No description provided for @examRuleTimer.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ العدّ التنازلي فور بدء الاختبار ولا يتوقف.'**
  String get examRuleTimer;

  /// No description provided for @examRuleAutosave.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ إجاباتك تلقائياً ويمكنك المتابعة إن أُغلق التطبيق.'**
  String get examRuleAutosave;

  /// No description provided for @examRuleAutoSubmit.
  ///
  /// In ar, this message translates to:
  /// **'يُسلَّم الاختبار تلقائياً عند انتهاء الوقت.'**
  String get examRuleAutoSubmit;

  /// No description provided for @examStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاختبار'**
  String get examStart;

  /// No description provided for @examResume.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الاختبار'**
  String get examResume;

  /// No description provided for @examStartConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدء الاختبار؟'**
  String get examStartConfirmTitle;

  /// No description provided for @examStartConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'مدة الاختبار {minutes} دقيقة وسيبدأ العدّ فوراً.'**
  String examStartConfirmBody(int minutes);

  /// No description provided for @examSignInToStart.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لبدء الاختبار'**
  String get examSignInToStart;

  /// No description provided for @examQuestionOf.
  ///
  /// In ar, this message translates to:
  /// **'السؤال {current} من {total}'**
  String examQuestionOf(int current, int total);

  /// No description provided for @examMarksLabel.
  ///
  /// In ar, this message translates to:
  /// **'{marks} درجة'**
  String examMarksLabel(String marks);

  /// No description provided for @examNavigator.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الأسئلة'**
  String get examNavigator;

  /// No description provided for @examLegendAnswered.
  ///
  /// In ar, this message translates to:
  /// **'مُجاب'**
  String get examLegendAnswered;

  /// No description provided for @examLegendUnanswered.
  ///
  /// In ar, this message translates to:
  /// **'غير مُجاب'**
  String get examLegendUnanswered;

  /// No description provided for @examLegendFlagged.
  ///
  /// In ar, this message translates to:
  /// **'للمراجعة'**
  String get examLegendFlagged;

  /// No description provided for @examFlag.
  ///
  /// In ar, this message translates to:
  /// **'تأشير للمراجعة'**
  String get examFlag;

  /// No description provided for @examUnflag.
  ///
  /// In ar, this message translates to:
  /// **'إزالة التأشير'**
  String get examUnflag;

  /// No description provided for @examClearAnswer.
  ///
  /// In ar, this message translates to:
  /// **'مسح الإجابة'**
  String get examClearAnswer;

  /// No description provided for @examSubmit.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الاختبار'**
  String get examSubmit;

  /// No description provided for @examSubmitConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الاختبار؟'**
  String get examSubmitConfirmTitle;

  /// No description provided for @examSubmitConfirmUnanswered.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count, plural, =1{سؤال واحد} other{{count} أسئلة}} بدون إجابة. هل تريد التسليم؟'**
  String examSubmitConfirmUnanswered(int count);

  /// No description provided for @examSubmitConfirmAll.
  ///
  /// In ar, this message translates to:
  /// **'أجبت عن كل الأسئلة. هل تريد التسليم؟'**
  String get examSubmitConfirmAll;

  /// No description provided for @examLeaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة الاختبار؟'**
  String get examLeaveTitle;

  /// No description provided for @examLeaveBody.
  ///
  /// In ar, this message translates to:
  /// **'يستمر الوقت بالعدّ وتُحفظ إجاباتك. يمكنك العودة لمتابعة الاختبار.'**
  String get examLeaveBody;

  /// No description provided for @examLeaveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة'**
  String get examLeaveConfirm;

  /// No description provided for @examTimeUpTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت'**
  String get examTimeUpTitle;

  /// No description provided for @examTimeUpBody.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تسليم إجاباتك تلقائياً…'**
  String get examTimeUpBody;

  /// No description provided for @examSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تسليم الاختبار. إجاباتك محفوظة، أعد المحاولة.'**
  String get examSubmitFailed;

  /// No description provided for @examSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التسليم…'**
  String get examSubmitting;

  /// No description provided for @examNoQuestions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسئلة في هذا الاختبار'**
  String get examNoQuestions;

  /// No description provided for @examResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الاختبار'**
  String get examResultTitle;

  /// No description provided for @examPassed.
  ///
  /// In ar, this message translates to:
  /// **'ناجح'**
  String get examPassed;

  /// No description provided for @examFailed.
  ///
  /// In ar, this message translates to:
  /// **'لم تجتز الاختبار'**
  String get examFailed;

  /// No description provided for @examCongrats.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! لقد اجتزت الاختبار'**
  String get examCongrats;

  /// No description provided for @examKeepGoing.
  ///
  /// In ar, this message translates to:
  /// **'لا بأس، راجع الدروس وحاول مجدداً'**
  String get examKeepGoing;

  /// No description provided for @examTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مجدداً'**
  String get examTryAgain;

  /// No description provided for @examScoreOf.
  ///
  /// In ar, this message translates to:
  /// **'{score} من {total}'**
  String examScoreOf(String score, String total);

  /// No description provided for @examStatCorrect.
  ///
  /// In ar, this message translates to:
  /// **'صحيحة'**
  String get examStatCorrect;

  /// No description provided for @examStatWrong.
  ///
  /// In ar, this message translates to:
  /// **'خاطئة'**
  String get examStatWrong;

  /// No description provided for @examStatUnanswered.
  ///
  /// In ar, this message translates to:
  /// **'بدون إجابة'**
  String get examStatUnanswered;

  /// No description provided for @examTimeTaken.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المستغرق: {minutes} دقيقة'**
  String examTimeTaken(String minutes);

  /// No description provided for @examReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الإجابات'**
  String get examReviewTitle;

  /// No description provided for @examYourAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك'**
  String get examYourAnswer;

  /// No description provided for @examCorrectAnswer.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة الصحيحة'**
  String get examCorrectAnswer;

  /// No description provided for @examExplanation.
  ///
  /// In ar, this message translates to:
  /// **'الشرح'**
  String get examExplanation;

  /// No description provided for @examNotAnswered.
  ///
  /// In ar, this message translates to:
  /// **'لم تجب عن هذا السؤال'**
  String get examNotAnswered;

  /// No description provided for @examShareResult.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة النتيجة'**
  String get examShareResult;

  /// No description provided for @examShareText.
  ///
  /// In ar, this message translates to:
  /// **'حصلت على {percent} في اختبار «{title}» عبر أكاديمية ابن زيدون 🎓'**
  String examShareText(String percent, String title);

  /// No description provided for @examResultReviewHidden.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر مراجعة الإجابات عند نشر النتائج.'**
  String get examResultReviewHidden;

  /// No description provided for @myExamsTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختباراتي'**
  String get myExamsTitle;

  /// No description provided for @myExamsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم تخض أي اختبار بعد'**
  String get myExamsEmptyTitle;

  /// No description provided for @myExamsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ أول اختبار لك وتابع تقدّمك هنا.'**
  String get myExamsEmptyBody;

  /// No description provided for @myExamsGate.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لعرض سجل اختباراتك.'**
  String get myExamsGate;

  /// No description provided for @examAttemptDate.
  ///
  /// In ar, this message translates to:
  /// **'بتاريخ {date}'**
  String examAttemptDate(String date);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تتعلم اليوم؟'**
  String get homeGreetingSubtitle;

  /// No description provided for @homeCategories.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get homeCategories;

  /// No description provided for @homeFeatured.
  ///
  /// In ar, this message translates to:
  /// **'دورات مميزة'**
  String get homeFeatured;

  /// No description provided for @homeTrending.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر رواجاً'**
  String get homeTrending;

  /// No description provided for @homeTopTeachers.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المدرّسين'**
  String get homeTopTeachers;

  /// No description provided for @homeQuickExams.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get homeQuickExams;

  /// No description provided for @homeQuickTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المدرّسون'**
  String get homeQuickTeachers;

  /// No description provided for @homeQuickMyExams.
  ///
  /// In ar, this message translates to:
  /// **'نتائجي'**
  String get homeQuickMyExams;

  /// No description provided for @homeQuickCourses.
  ///
  /// In ar, this message translates to:
  /// **'كل الدورات'**
  String get homeQuickCourses;

  /// No description provided for @homeStatStudents.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get homeStatStudents;

  /// No description provided for @homeStatTeachers.
  ///
  /// In ar, this message translates to:
  /// **'مدرّس'**
  String get homeStatTeachers;

  /// No description provided for @homeStatCourses.
  ///
  /// In ar, this message translates to:
  /// **'دورة'**
  String get homeStatCourses;

  /// No description provided for @homeSectionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل هذا القسم'**
  String get homeSectionFailed;

  /// No description provided for @homeGuestPrompt.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لرؤية الدورات المميزة والمدرّسين وتقدّمك.'**
  String get homeGuestPrompt;

  /// No description provided for @notificationsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTooltip;

  /// No description provided for @notificationsBadgeLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} إشعارات غير مقروءة'**
  String notificationsBadgeLabel(int count);

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'سنعلمك هنا بكل جديد في دوراتك واختباراتك.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsGate.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لعرض إشعاراتك.'**
  String get notificationsGate;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'ابقَ على اطّلاع'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الإشعارات لتصلك تنبيهات الدروس الجديدة ونتائج الاختبارات وتذكيرات الدراسة.'**
  String get notificationPermissionBody;

  /// No description provided for @notificationPermissionEnable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get notificationPermissionEnable;

  /// No description provided for @notificationPermissionLater.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get notificationPermissionLater;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @profileGate.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لإدارة حسابك وتتبّع تقدّمك.'**
  String get profileGate;

  /// No description provided for @profileStatCourses.
  ///
  /// In ar, this message translates to:
  /// **'دورات'**
  String get profileStatCourses;

  /// No description provided for @profileStatCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get profileStatCompleted;

  /// No description provided for @profileStatExams.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات'**
  String get profileStatExams;

  /// No description provided for @profileStatLessons.
  ///
  /// In ar, this message translates to:
  /// **'دروس'**
  String get profileStatLessons;

  /// No description provided for @profileStatHours.
  ///
  /// In ar, this message translates to:
  /// **'ساعات'**
  String get profileStatHours;

  /// No description provided for @profileStatPassed.
  ///
  /// In ar, this message translates to:
  /// **'ناجح'**
  String get profileStatPassed;

  /// No description provided for @profileEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profileEdit;

  /// No description provided for @profileChangePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get profileChangePassword;

  /// No description provided for @profileMyExams.
  ///
  /// In ar, this message translates to:
  /// **'سجل اختباراتي'**
  String get profileMyExams;

  /// No description provided for @profileExamsCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز الاختبارات'**
  String get profileExamsCenter;

  /// No description provided for @profileTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المدرّسون'**
  String get profileTeachers;

  /// No description provided for @profileSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get profileSettings;

  /// No description provided for @profileLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج؟'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تسجيل الدخول مجدداً في أي وقت.'**
  String get profileLogoutConfirmBody;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteStep1Title.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك؟'**
  String get profileDeleteStep1Title;

  /// No description provided for @profileDeleteStep1Body.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تعطيل حسابك وتسجيل خروجك من جميع الأجهزة.'**
  String get profileDeleteStep1Body;

  /// No description provided for @profileDeleteStep2Title.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد نهائي'**
  String get profileDeleteStep2Title;

  /// No description provided for @profileDeleteStep2Body.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد تماماً؟'**
  String get profileDeleteStep2Body;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'نعم، احذف حسابي'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف الحساب. حاول مجدداً.'**
  String get profileDeleteFailed;

  /// No description provided for @profileSectionAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionLearning.
  ///
  /// In ar, this message translates to:
  /// **'التعلّم'**
  String get profileSectionLearning;

  /// No description provided for @profileSectionMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get profileSectionMore;

  /// No description provided for @profileEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profileEditTitle;

  /// No description provided for @profileEditSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات'**
  String get profileEditSaved;

  /// No description provided for @profileFieldNationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوطني'**
  String get profileFieldNationalId;

  /// No description provided for @profileFieldGender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get profileFieldGender;

  /// No description provided for @profileGenderMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get profileGenderFemale;

  /// No description provided for @profileFieldBirthDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get profileFieldBirthDate;

  /// No description provided for @profileFieldNationality.
  ///
  /// In ar, this message translates to:
  /// **'الجنسية'**
  String get profileFieldNationality;

  /// No description provided for @profileAvatarChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get profileAvatarChange;

  /// No description provided for @profileAvatarTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم الصورة يجب ألا يتجاوز 2 ميغابايت'**
  String get profileAvatarTooLarge;

  /// No description provided for @profileAvatarFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'من المعرض'**
  String get profileAvatarFromGallery;

  /// No description provided for @profileAvatarFromCamera.
  ///
  /// In ar, this message translates to:
  /// **'من الكاميرا'**
  String get profileAvatarFromCamera;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get passwordChangeTitle;

  /// No description provided for @passwordChangeSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور'**
  String get passwordChangeSaved;

  /// No description provided for @passwordChangeAction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كلمة المرور'**
  String get passwordChangeAction;

  /// No description provided for @passwordChangeWrongCurrent.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية غير صحيحة'**
  String get passwordChangeWrongCurrent;

  /// No description provided for @schoolAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get schoolAnnouncements;

  /// No description provided for @schoolConduct.
  ///
  /// In ar, this message translates to:
  /// **'ميثاق السلوك'**
  String get schoolConduct;

  /// No description provided for @schoolPlanner.
  ///
  /// In ar, this message translates to:
  /// **'المخطط الدراسي'**
  String get schoolPlanner;

  /// No description provided for @schoolPlannerNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات اليوم'**
  String get schoolPlannerNotes;

  /// No description provided for @schoolPlannerWeekly.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get schoolPlannerWeekly;

  /// No description provided for @schoolSchedules.
  ///
  /// In ar, this message translates to:
  /// **'الجداول'**
  String get schoolSchedules;

  /// No description provided for @schoolScheduleClass.
  ///
  /// In ar, this message translates to:
  /// **'جدول الحصص'**
  String get schoolScheduleClass;

  /// No description provided for @schoolScheduleExam.
  ///
  /// In ar, this message translates to:
  /// **'جدول الاختبارات'**
  String get schoolScheduleExam;

  /// No description provided for @conductSign.
  ///
  /// In ar, this message translates to:
  /// **'أوافق وأوقّع'**
  String get conductSign;

  /// No description provided for @conductSigned.
  ///
  /// In ar, this message translates to:
  /// **'تم توقيع الميثاق'**
  String get conductSigned;

  /// No description provided for @siblingSwitchTitle.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الحساب'**
  String get siblingSwitchTitle;

  /// No description provided for @siblingSwitchHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الحساب المرتبط'**
  String get siblingSwitchHint;

  /// No description provided for @siblingSwitchAction.
  ///
  /// In ar, this message translates to:
  /// **'تبديل'**
  String get siblingSwitchAction;

  /// No description provided for @siblingSwitched.
  ///
  /// In ar, this message translates to:
  /// **'تم تبديل الحساب'**
  String get siblingSwitched;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In ar, this message translates to:
  /// **'{greeting}، {name}'**
  String homeGreetingWithName(String greeting, String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
