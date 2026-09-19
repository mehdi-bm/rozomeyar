import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'رزومه یار پارسیک'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fa, this message translates to:
  /// **'رزومه حرفه‌ای، فرصت بهتر'**
  String get appTagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'رزومه حرفه‌ای خودت را بساز'**
  String get splashSubtitle;

  /// No description provided for @commonSave.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get commonSave;

  /// No description provided for @commonSaveAndClose.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره و بستن'**
  String get commonSaveAndClose;

  /// No description provided for @commonCancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get commonAdd;

  /// No description provided for @commonNext.
  ///
  /// In fa, this message translates to:
  /// **'بعدی'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In fa, this message translates to:
  /// **'قبلی'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In fa, this message translates to:
  /// **'پایان'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In fa, this message translates to:
  /// **'تأیید'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get commonRetry;

  /// No description provided for @commonOptional.
  ///
  /// In fa, this message translates to:
  /// **'اختیاری'**
  String get commonOptional;

  /// No description provided for @commonPreview.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش'**
  String get commonPreview;

  /// No description provided for @commonShare.
  ///
  /// In fa, this message translates to:
  /// **'اشتراک‌گذاری'**
  String get commonShare;

  /// No description provided for @commonDuplicate.
  ///
  /// In fa, this message translates to:
  /// **'تهیه کپی'**
  String get commonDuplicate;

  /// No description provided for @commonRemove.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get commonRemove;

  /// No description provided for @commonMore.
  ///
  /// In fa, this message translates to:
  /// **'بیشتر'**
  String get commonMore;

  /// No description provided for @commonSelect.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب'**
  String get commonSelect;

  /// No description provided for @commonClear.
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن'**
  String get commonClear;

  /// No description provided for @homeTitle.
  ///
  /// In fa, this message translates to:
  /// **'رزومه‌های من'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In fa, this message translates to:
  /// **'هنوز رزومه‌ای نساخته‌اید'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In fa, this message translates to:
  /// **'اولین رزومه حرفه‌ای خود را بسازید'**
  String get homeEmptySubtitle;

  /// No description provided for @homeCreateCta.
  ///
  /// In fa, this message translates to:
  /// **'ساخت رزومه جدید'**
  String get homeCreateCta;

  /// No description provided for @homeLastEdited.
  ///
  /// In fa, this message translates to:
  /// **'آخرین ویرایش: {date}'**
  String homeLastEdited(String date);

  /// No description provided for @homeSampleBadge.
  ///
  /// In fa, this message translates to:
  /// **'نمونه رزومه'**
  String get homeSampleBadge;

  /// No description provided for @homeDeleteTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف رزومه'**
  String get homeDeleteTitle;

  /// No description provided for @homeDeleteMessage.
  ///
  /// In fa, this message translates to:
  /// **'رزومه «{title}» حذف شود؟ این کار قابل بازگشت نیست.'**
  String homeDeleteMessage(String title);

  /// No description provided for @homeDeleted.
  ///
  /// In fa, this message translates to:
  /// **'رزومه حذف شد'**
  String get homeDeleted;

  /// No description provided for @homeDuplicated.
  ///
  /// In fa, this message translates to:
  /// **'کپی رزومه ساخته شد'**
  String get homeDuplicated;

  /// No description provided for @homeCopySuffix.
  ///
  /// In fa, this message translates to:
  /// **'کپی'**
  String get homeCopySuffix;

  /// No description provided for @homeNewResumeTitle.
  ///
  /// In fa, this message translates to:
  /// **'رزومه جدید'**
  String get homeNewResumeTitle;

  /// No description provided for @homeCreateSheetTitle.
  ///
  /// In fa, this message translates to:
  /// **'ساخت رزومه جدید'**
  String get homeCreateSheetTitle;

  /// No description provided for @homeCreateSheetLanguage.
  ///
  /// In fa, this message translates to:
  /// **'زبان رزومه'**
  String get homeCreateSheetLanguage;

  /// No description provided for @homeCreateSheetName.
  ///
  /// In fa, this message translates to:
  /// **'نام رزومه'**
  String get homeCreateSheetName;

  /// No description provided for @homeCreateSheetNameHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: رزومه توسعه‌دهنده موبایل'**
  String get homeCreateSheetNameHint;

  /// No description provided for @homeRename.
  ///
  /// In fa, this message translates to:
  /// **'تغییر نام'**
  String get homeRename;

  /// No description provided for @favoriteAdd.
  ///
  /// In fa, this message translates to:
  /// **'افزودن به موردعلاقه‌ها'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In fa, this message translates to:
  /// **'حذف از موردعلاقه‌ها'**
  String get favoriteRemove;

  /// No description provided for @filterAll.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get filterAll;

  /// No description provided for @filterFavorites.
  ///
  /// In fa, this message translates to:
  /// **'ستاره‌دار'**
  String get filterFavorites;

  /// No description provided for @filterEmpty.
  ///
  /// In fa, this message translates to:
  /// **'رزومه‌ای با این فیلتر پیدا نشد'**
  String get filterEmpty;

  /// No description provided for @filterShowAll.
  ///
  /// In fa, this message translates to:
  /// **'نمایش همه'**
  String get filterShowAll;

  /// No description provided for @homeRenameTitle.
  ///
  /// In fa, this message translates to:
  /// **'تغییر نام رزومه'**
  String get homeRenameTitle;

  /// No description provided for @resumeLanguagePersian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get resumeLanguagePersian;

  /// No description provided for @resumeLanguageEnglish.
  ///
  /// In fa, this message translates to:
  /// **'انگلیسی'**
  String get resumeLanguageEnglish;

  /// No description provided for @resumeLanguageArabic.
  ///
  /// In fa, this message translates to:
  /// **'عربی'**
  String get resumeLanguageArabic;

  /// No description provided for @resumeLanguageLabel.
  ///
  /// In fa, this message translates to:
  /// **'زبان رزومه'**
  String get resumeLanguageLabel;

  /// No description provided for @translateTitle.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه رزومه'**
  String get translateTitle;

  /// No description provided for @translateTo.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه به'**
  String get translateTo;

  /// No description provided for @translateAction.
  ///
  /// In fa, this message translates to:
  /// **'شروع ترجمه'**
  String get translateAction;

  /// No description provided for @translateWarning.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه ماشینی است و ممکن است اشتباه داشته باشد. پیش از ارسال رزومه، متن ترجمه‌شده را بازبینی کنید.'**
  String get translateWarning;

  /// No description provided for @translateArabicWarning.
  ///
  /// In fa, this message translates to:
  /// **'کیفیت ترجمه عربی برای جمله‌های کامل خوب است، اما عنوان‌های شغلی و عبارت‌های کوتاه اغلب نیاز به اصلاح دارند.'**
  String get translateArabicWarning;

  /// No description provided for @translateOfflineNote.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه روی همین دستگاه انجام می‌شود و متن رزومه شما به هیچ سروری ارسال نمی‌شود.'**
  String get translateOfflineNote;

  /// No description provided for @translateModelNeeded.
  ///
  /// In fa, this message translates to:
  /// **'برای این زبان باید یک‌بار بسته زبانی دانلود شود (حدود ۳۰ مگابایت). پس از آن ترجمه بدون اینترنت کار می‌کند.'**
  String get translateModelNeeded;

  /// No description provided for @translateModelReady.
  ///
  /// In fa, this message translates to:
  /// **'بسته زبانی روی دستگاه موجود است. نیازی به اینترنت نیست.'**
  String get translateModelReady;

  /// No description provided for @translateDownloading.
  ///
  /// In fa, this message translates to:
  /// **'در حال دانلود بسته زبانی...'**
  String get translateDownloading;

  /// No description provided for @translateWorking.
  ///
  /// In fa, this message translates to:
  /// **'در حال ترجمه...'**
  String get translateWorking;

  /// No description provided for @translateProgress.
  ///
  /// In fa, this message translates to:
  /// **'{done} از {total}'**
  String translateProgress(int done, int total);

  /// No description provided for @translateDone.
  ///
  /// In fa, this message translates to:
  /// **'رزومه ترجمه‌شده ساخته شد'**
  String get translateDone;

  /// No description provided for @translateNewTitle.
  ///
  /// In fa, this message translates to:
  /// **'{title} ({language})'**
  String translateNewTitle(String title, String language);

  /// No description provided for @stepPersonalInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات شخصی'**
  String get stepPersonalInfo;

  /// No description provided for @stepSummary.
  ///
  /// In fa, this message translates to:
  /// **'درباره من'**
  String get stepSummary;

  /// No description provided for @stepExperience.
  ///
  /// In fa, this message translates to:
  /// **'سوابق کاری'**
  String get stepExperience;

  /// No description provided for @stepEducation.
  ///
  /// In fa, this message translates to:
  /// **'تحصیلات'**
  String get stepEducation;

  /// No description provided for @stepSkills.
  ///
  /// In fa, this message translates to:
  /// **'مهارت‌ها'**
  String get stepSkills;

  /// No description provided for @stepLanguages.
  ///
  /// In fa, this message translates to:
  /// **'زبان‌ها'**
  String get stepLanguages;

  /// No description provided for @stepProjects.
  ///
  /// In fa, this message translates to:
  /// **'پروژه‌ها'**
  String get stepProjects;

  /// No description provided for @stepCertifications.
  ///
  /// In fa, this message translates to:
  /// **'دوره‌ها و گواهینامه‌ها'**
  String get stepCertifications;

  /// No description provided for @stepLinks.
  ///
  /// In fa, this message translates to:
  /// **'لینک‌ها'**
  String get stepLinks;

  /// No description provided for @stepTemplate.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب قالب'**
  String get stepTemplate;

  /// No description provided for @stepPreview.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش'**
  String get stepPreview;

  /// No description provided for @stepProgress.
  ///
  /// In fa, this message translates to:
  /// **'گام {current} از {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @fieldFirstName.
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In fa, this message translates to:
  /// **'نام خانوادگی'**
  String get fieldLastName;

  /// No description provided for @fieldJobTitle.
  ///
  /// In fa, this message translates to:
  /// **'عنوان شغلی'**
  String get fieldJobTitle;

  /// No description provided for @fieldJobTitleHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: توسعه‌دهنده ارشد نرم‌افزار'**
  String get fieldJobTitleHint;

  /// No description provided for @fieldPhoto.
  ///
  /// In fa, this message translates to:
  /// **'عکس پروفایل'**
  String get fieldPhoto;

  /// No description provided for @fieldMobile.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get fieldMobile;

  /// No description provided for @fieldEmail.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل'**
  String get fieldEmail;

  /// No description provided for @fieldCity.
  ///
  /// In fa, this message translates to:
  /// **'شهر'**
  String get fieldCity;

  /// No description provided for @fieldCountry.
  ///
  /// In fa, this message translates to:
  /// **'کشور'**
  String get fieldCountry;

  /// No description provided for @fieldBirthDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد'**
  String get fieldBirthDate;

  /// No description provided for @fieldAddress.
  ///
  /// In fa, this message translates to:
  /// **'آدرس'**
  String get fieldAddress;

  /// No description provided for @fieldMaritalStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت تأهل'**
  String get fieldMaritalStatus;

  /// No description provided for @maritalSingle.
  ///
  /// In fa, this message translates to:
  /// **'مجرد'**
  String get maritalSingle;

  /// No description provided for @maritalMarried.
  ///
  /// In fa, this message translates to:
  /// **'متأهل'**
  String get maritalMarried;

  /// No description provided for @photoAdd.
  ///
  /// In fa, this message translates to:
  /// **'افزودن عکس'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In fa, this message translates to:
  /// **'تغییر عکس'**
  String get photoChange;

  /// No description provided for @photoFromCamera.
  ///
  /// In fa, this message translates to:
  /// **'دوربین'**
  String get photoFromCamera;

  /// No description provided for @photoFromGallery.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب از گالری'**
  String get photoFromGallery;

  /// No description provided for @photoRemove.
  ///
  /// In fa, this message translates to:
  /// **'حذف عکس'**
  String get photoRemove;

  /// No description provided for @optionalFieldsTitle.
  ///
  /// In fa, this message translates to:
  /// **'نمایش در رزومه'**
  String get optionalFieldsTitle;

  /// No description provided for @optionalFieldsSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'مشخص کنید کدام اطلاعات اختیاری در رزومه نهایی دیده شوند.'**
  String get optionalFieldsSubtitle;

  /// No description provided for @summaryTitle.
  ///
  /// In fa, this message translates to:
  /// **'خلاصه حرفه‌ای'**
  String get summaryTitle;

  /// No description provided for @summaryHint.
  ///
  /// In fa, this message translates to:
  /// **'خلاصه‌ای کوتاه درباره تجربه، تخصص و اهداف حرفه‌ای خود بنویسید...'**
  String get summaryHint;

  /// No description provided for @summaryRecommendation.
  ///
  /// In fa, this message translates to:
  /// **'پیشنهاد می‌شود بین ۳۰۰ تا ۶۰۰ کاراکتر بنویسید.'**
  String get summaryRecommendation;

  /// No description provided for @summaryCharCount.
  ///
  /// In fa, this message translates to:
  /// **'{count} کاراکتر'**
  String summaryCharCount(int count);

  /// No description provided for @fieldCompany.
  ///
  /// In fa, this message translates to:
  /// **'نام شرکت'**
  String get fieldCompany;

  /// No description provided for @fieldStartDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ شروع'**
  String get fieldStartDate;

  /// No description provided for @fieldEndDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ پایان'**
  String get fieldEndDate;

  /// No description provided for @fieldCurrentlyWorking.
  ///
  /// In fa, this message translates to:
  /// **'هم‌اکنون در اینجا مشغول به کار هستم'**
  String get fieldCurrentlyWorking;

  /// No description provided for @fieldDescription.
  ///
  /// In fa, this message translates to:
  /// **'توضیحات'**
  String get fieldDescription;

  /// No description provided for @fieldAchievements.
  ///
  /// In fa, this message translates to:
  /// **'دستاوردها'**
  String get fieldAchievements;

  /// No description provided for @fieldAchievementsHint.
  ///
  /// In fa, this message translates to:
  /// **'هر دستاورد را در یک خط بنویسید.'**
  String get fieldAchievementsHint;

  /// No description provided for @dateNow.
  ///
  /// In fa, this message translates to:
  /// **'تاکنون'**
  String get dateNow;

  /// No description provided for @fieldDegree.
  ///
  /// In fa, this message translates to:
  /// **'مقطع تحصیلی'**
  String get fieldDegree;

  /// No description provided for @fieldFieldOfStudy.
  ///
  /// In fa, this message translates to:
  /// **'رشته تحصیلی'**
  String get fieldFieldOfStudy;

  /// No description provided for @fieldInstitution.
  ///
  /// In fa, this message translates to:
  /// **'دانشگاه / مؤسسه'**
  String get fieldInstitution;

  /// No description provided for @fieldSkillName.
  ///
  /// In fa, this message translates to:
  /// **'نام مهارت'**
  String get fieldSkillName;

  /// No description provided for @fieldSkillLevel.
  ///
  /// In fa, this message translates to:
  /// **'سطح مهارت'**
  String get fieldSkillLevel;

  /// No description provided for @skillLevelBeginner.
  ///
  /// In fa, this message translates to:
  /// **'مقدماتی'**
  String get skillLevelBeginner;

  /// No description provided for @skillLevelIntermediate.
  ///
  /// In fa, this message translates to:
  /// **'متوسط'**
  String get skillLevelIntermediate;

  /// No description provided for @skillLevelAdvanced.
  ///
  /// In fa, this message translates to:
  /// **'پیشرفته'**
  String get skillLevelAdvanced;

  /// No description provided for @skillLevelExpert.
  ///
  /// In fa, this message translates to:
  /// **'حرفه‌ای'**
  String get skillLevelExpert;

  /// No description provided for @skillsShowLevels.
  ///
  /// In fa, this message translates to:
  /// **'نمایش سطح مهارت در رزومه'**
  String get skillsShowLevels;

  /// No description provided for @skillAddHint.
  ///
  /// In fa, this message translates to:
  /// **'نام مهارت را بنویسید و افزودن را بزنید'**
  String get skillAddHint;

  /// No description provided for @fieldLanguageName.
  ///
  /// In fa, this message translates to:
  /// **'نام زبان'**
  String get fieldLanguageName;

  /// No description provided for @fieldLanguageLevel.
  ///
  /// In fa, this message translates to:
  /// **'سطح تسلط'**
  String get fieldLanguageLevel;

  /// No description provided for @langLevelBasic.
  ///
  /// In fa, this message translates to:
  /// **'مقدماتی'**
  String get langLevelBasic;

  /// No description provided for @langLevelIntermediate.
  ///
  /// In fa, this message translates to:
  /// **'متوسط'**
  String get langLevelIntermediate;

  /// No description provided for @langLevelProfessional.
  ///
  /// In fa, this message translates to:
  /// **'پیشرفته'**
  String get langLevelProfessional;

  /// No description provided for @langLevelFluent.
  ///
  /// In fa, this message translates to:
  /// **'مسلط'**
  String get langLevelFluent;

  /// No description provided for @langLevelNative.
  ///
  /// In fa, this message translates to:
  /// **'زبان مادری'**
  String get langLevelNative;

  /// No description provided for @fieldProjectName.
  ///
  /// In fa, this message translates to:
  /// **'نام پروژه'**
  String get fieldProjectName;

  /// No description provided for @fieldRole.
  ///
  /// In fa, this message translates to:
  /// **'نقش شما'**
  String get fieldRole;

  /// No description provided for @fieldTechnologies.
  ///
  /// In fa, this message translates to:
  /// **'تکنولوژی‌ها'**
  String get fieldTechnologies;

  /// No description provided for @fieldTechnologiesHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: Flutter، Firebase، REST API'**
  String get fieldTechnologiesHint;

  /// No description provided for @fieldProjectUrl.
  ///
  /// In fa, this message translates to:
  /// **'لینک پروژه'**
  String get fieldProjectUrl;

  /// No description provided for @fieldCertificateName.
  ///
  /// In fa, this message translates to:
  /// **'نام دوره یا گواهینامه'**
  String get fieldCertificateName;

  /// No description provided for @fieldOrganization.
  ///
  /// In fa, this message translates to:
  /// **'مؤسسه صادرکننده'**
  String get fieldOrganization;

  /// No description provided for @fieldIssueDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ دریافت'**
  String get fieldIssueDate;

  /// No description provided for @fieldCredentialUrl.
  ///
  /// In fa, this message translates to:
  /// **'لینک گواهینامه'**
  String get fieldCredentialUrl;

  /// No description provided for @fieldLinkTitle.
  ///
  /// In fa, this message translates to:
  /// **'عنوان'**
  String get fieldLinkTitle;

  /// No description provided for @fieldLinkUrl.
  ///
  /// In fa, this message translates to:
  /// **'آدرس'**
  String get fieldLinkUrl;

  /// No description provided for @linkTypeLinkedin.
  ///
  /// In fa, this message translates to:
  /// **'لینکدین'**
  String get linkTypeLinkedin;

  /// No description provided for @linkTypeGithub.
  ///
  /// In fa, this message translates to:
  /// **'گیت‌هاب'**
  String get linkTypeGithub;

  /// No description provided for @linkTypePortfolio.
  ///
  /// In fa, this message translates to:
  /// **'نمونه‌کارها'**
  String get linkTypePortfolio;

  /// No description provided for @linkTypeWebsite.
  ///
  /// In fa, this message translates to:
  /// **'وب‌سایت'**
  String get linkTypeWebsite;

  /// No description provided for @linkTypeTelegram.
  ///
  /// In fa, this message translates to:
  /// **'تلگرام'**
  String get linkTypeTelegram;

  /// No description provided for @linkTypeOther.
  ///
  /// In fa, this message translates to:
  /// **'سایر'**
  String get linkTypeOther;

  /// No description provided for @linkTypeLabel.
  ///
  /// In fa, this message translates to:
  /// **'نوع لینک'**
  String get linkTypeLabel;

  /// No description provided for @emptyExperience.
  ///
  /// In fa, this message translates to:
  /// **'هنوز سابقه کاری اضافه نکرده‌اید'**
  String get emptyExperience;

  /// No description provided for @emptyEducation.
  ///
  /// In fa, this message translates to:
  /// **'هنوز سابقه تحصیلی اضافه نکرده‌اید'**
  String get emptyEducation;

  /// No description provided for @emptySkills.
  ///
  /// In fa, this message translates to:
  /// **'هنوز مهارتی اضافه نکرده‌اید'**
  String get emptySkills;

  /// No description provided for @emptyLanguages.
  ///
  /// In fa, this message translates to:
  /// **'هنوز زبانی اضافه نکرده‌اید'**
  String get emptyLanguages;

  /// No description provided for @emptyProjects.
  ///
  /// In fa, this message translates to:
  /// **'هنوز پروژه‌ای اضافه نکرده‌اید'**
  String get emptyProjects;

  /// No description provided for @emptyCertifications.
  ///
  /// In fa, this message translates to:
  /// **'هنوز دوره یا گواهینامه‌ای اضافه نکرده‌اید'**
  String get emptyCertifications;

  /// No description provided for @emptyLinks.
  ///
  /// In fa, this message translates to:
  /// **'هنوز لینکی اضافه نکرده‌اید'**
  String get emptyLinks;

  /// No description provided for @emptySectionHint.
  ///
  /// In fa, this message translates to:
  /// **'این بخش اختیاری است و در صورت خالی بودن در رزومه نمایش داده نمی‌شود.'**
  String get emptySectionHint;

  /// No description provided for @addExperience.
  ///
  /// In fa, this message translates to:
  /// **'افزودن سابقه کاری'**
  String get addExperience;

  /// No description provided for @addEducation.
  ///
  /// In fa, this message translates to:
  /// **'افزودن تحصیلات'**
  String get addEducation;

  /// No description provided for @addSkill.
  ///
  /// In fa, this message translates to:
  /// **'افزودن مهارت'**
  String get addSkill;

  /// No description provided for @addLanguage.
  ///
  /// In fa, this message translates to:
  /// **'افزودن زبان'**
  String get addLanguage;

  /// No description provided for @addProject.
  ///
  /// In fa, this message translates to:
  /// **'افزودن پروژه'**
  String get addProject;

  /// No description provided for @addCertification.
  ///
  /// In fa, this message translates to:
  /// **'افزودن دوره یا گواهینامه'**
  String get addCertification;

  /// No description provided for @addLink.
  ///
  /// In fa, this message translates to:
  /// **'افزودن لینک'**
  String get addLink;

  /// No description provided for @editExperience.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش سابقه کاری'**
  String get editExperience;

  /// No description provided for @editEducation.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش تحصیلات'**
  String get editEducation;

  /// No description provided for @editSkill.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش مهارت'**
  String get editSkill;

  /// No description provided for @editLanguage.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش زبان'**
  String get editLanguage;

  /// No description provided for @editProject.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش پروژه'**
  String get editProject;

  /// No description provided for @editCertification.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش دوره یا گواهینامه'**
  String get editCertification;

  /// No description provided for @editLink.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش لینک'**
  String get editLink;

  /// No description provided for @reorderHint.
  ///
  /// In fa, this message translates to:
  /// **'برای جابه‌جایی، آیتم را بکشید و رها کنید.'**
  String get reorderHint;

  /// No description provided for @deleteItemTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف آیتم'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In fa, this message translates to:
  /// **'این مورد حذف شود؟'**
  String get deleteItemMessage;

  /// No description provided for @templatesTitle.
  ///
  /// In fa, this message translates to:
  /// **'قالب‌ها'**
  String get templatesTitle;

  /// No description provided for @templateClassic.
  ///
  /// In fa, this message translates to:
  /// **'کلاسیک'**
  String get templateClassic;

  /// No description provided for @templateClassicDesc.
  ///
  /// In fa, this message translates to:
  /// **'ساده و رسمی، مناسب مشاغل سازمانی و اداری'**
  String get templateClassicDesc;

  /// No description provided for @templateModern.
  ///
  /// In fa, this message translates to:
  /// **'مدرن'**
  String get templateModern;

  /// No description provided for @templateModernDesc.
  ///
  /// In fa, this message translates to:
  /// **'دو ستونی با ستون کناری مهارت‌ها و عکس پروفایل'**
  String get templateModernDesc;

  /// No description provided for @templateMinimal.
  ///
  /// In fa, this message translates to:
  /// **'مینیمال'**
  String get templateMinimal;

  /// No description provided for @templateMinimalDesc.
  ///
  /// In fa, this message translates to:
  /// **'بسیار تمیز با فضای سفید زیاد و تمرکز بر تایپوگرافی'**
  String get templateMinimalDesc;

  /// No description provided for @templateProBadge.
  ///
  /// In fa, this message translates to:
  /// **'ویژه'**
  String get templateProBadge;

  /// No description provided for @customizeTitle.
  ///
  /// In fa, this message translates to:
  /// **'شخصی‌سازی'**
  String get customizeTitle;

  /// No description provided for @customizeAccent.
  ///
  /// In fa, this message translates to:
  /// **'رنگ اصلی'**
  String get customizeAccent;

  /// No description provided for @customizeShowPhoto.
  ///
  /// In fa, this message translates to:
  /// **'نمایش عکس پروفایل'**
  String get customizeShowPhoto;

  /// No description provided for @customizeShowPhotoDisabled.
  ///
  /// In fa, this message translates to:
  /// **'این قالب از عکس پروفایل پشتیبانی نمی‌کند'**
  String get customizeShowPhotoDisabled;

  /// No description provided for @customizeFontSize.
  ///
  /// In fa, this message translates to:
  /// **'اندازه فونت'**
  String get customizeFontSize;

  /// No description provided for @fontSizeSmall.
  ///
  /// In fa, this message translates to:
  /// **'کوچک'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeNormal.
  ///
  /// In fa, this message translates to:
  /// **'معمولی'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarge.
  ///
  /// In fa, this message translates to:
  /// **'بزرگ'**
  String get fontSizeLarge;

  /// No description provided for @previewTitle.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش رزومه'**
  String get previewTitle;

  /// No description provided for @previewExport.
  ///
  /// In fa, this message translates to:
  /// **'خروجی PDF'**
  String get previewExport;

  /// No description provided for @previewShare.
  ///
  /// In fa, this message translates to:
  /// **'اشتراک‌گذاری'**
  String get previewShare;

  /// No description provided for @previewGenerating.
  ///
  /// In fa, this message translates to:
  /// **'در حال ساخت فایل PDF...'**
  String get previewGenerating;

  /// No description provided for @previewSaved.
  ///
  /// In fa, this message translates to:
  /// **'فایل PDF ذخیره شد'**
  String get previewSaved;

  /// No description provided for @previewSavedAt.
  ///
  /// In fa, this message translates to:
  /// **'فایل در {path} ذخیره شد'**
  String previewSavedAt(String path);

  /// No description provided for @previewChangeTemplate.
  ///
  /// In fa, this message translates to:
  /// **'تغییر قالب'**
  String get previewChangeTemplate;

  /// No description provided for @settingsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In fa, this message translates to:
  /// **'عمومی'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In fa, this message translates to:
  /// **'درباره'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In fa, this message translates to:
  /// **'زبان برنامه'**
  String get settingsAppLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In fa, this message translates to:
  /// **'پوسته'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌فرض سیستم'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fa, this message translates to:
  /// **'روشن'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fa, this message translates to:
  /// **'تاریک'**
  String get themeDark;

  /// No description provided for @settingsDefaultResumeLanguage.
  ///
  /// In fa, this message translates to:
  /// **'زبان پیش‌فرض رزومه'**
  String get settingsDefaultResumeLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In fa, this message translates to:
  /// **'درباره رزومه‌یار'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fa, this message translates to:
  /// **'حریم خصوصی'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In fa, this message translates to:
  /// **'نسخه {version}'**
  String settingsVersion(String version);

  /// No description provided for @privacyTitle.
  ///
  /// In fa, this message translates to:
  /// **'حریم خصوصی'**
  String get privacyTitle;

  /// No description provided for @privacyLocalStorage.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات رزومه شما روی دستگاه ذخیره می‌شود.'**
  String get privacyLocalStorage;

  /// No description provided for @privacyBody.
  ///
  /// In fa, this message translates to:
  /// **'رزومه‌یار هیچ اطلاعاتی را به سرور ارسال نمی‌کند. تمام رزومه‌ها، عکس‌ها و تنظیمات فقط روی همین دستگاه نگهداری می‌شوند و با حذف برنامه، این اطلاعات نیز پاک می‌شوند.'**
  String get privacyBody;

  /// No description provided for @privacyNoAccount.
  ///
  /// In fa, this message translates to:
  /// **'برای استفاده از برنامه نیازی به ثبت‌نام یا ورود نیست.'**
  String get privacyNoAccount;

  /// No description provided for @privacyNoInternet.
  ///
  /// In fa, this message translates to:
  /// **'برنامه برای ساخت، ویرایش و خروجی گرفتن از رزومه به اینترنت نیاز ندارد.'**
  String get privacyNoInternet;

  /// No description provided for @privacyTranslation.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه رزومه روی همین دستگاه انجام می‌شود و متن رزومه شما به هیچ سروری ارسال نمی‌شود. تنها موردی که به اینترنت نیاز دارد، دانلود یک‌باره بسته زبانی برای هر زبان است.'**
  String get privacyTranslation;

  /// No description provided for @privacyPermissions.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی به دوربین و گالری تنها زمانی استفاده می‌شود که خودتان بخواهید عکس پروفایل اضافه کنید.'**
  String get privacyPermissions;

  /// No description provided for @aboutTitle.
  ///
  /// In fa, this message translates to:
  /// **'درباره رزومه‌یار'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In fa, this message translates to:
  /// **'رزومه‌یار به شما کمک می‌کند در چند دقیقه یک رزومه حرفه‌ای فارسی یا انگلیسی بسازید و آن را به صورت فایل PDF با کیفیت ذخیره یا ارسال کنید.'**
  String get aboutBody;

  /// No description provided for @validationRequired.
  ///
  /// In fa, this message translates to:
  /// **'این فیلد الزامی است'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل معتبر نیست'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidUrl.
  ///
  /// In fa, this message translates to:
  /// **'آدرس اینترنتی معتبر نیست'**
  String get validationInvalidUrl;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً نام را وارد کنید'**
  String get validationFirstNameRequired;

  /// No description provided for @validationLastNameRequired.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً نام خانوادگی را وارد کنید'**
  String get validationLastNameRequired;

  /// No description provided for @errorGeneric.
  ///
  /// In fa, this message translates to:
  /// **'مشکلی پیش آمد. لطفاً دوباره تلاش کنید.'**
  String get errorGeneric;

  /// No description provided for @errorPdfGeneration.
  ///
  /// In fa, this message translates to:
  /// **'ساخت فایل PDF انجام نشد. لطفاً دوباره تلاش کنید.'**
  String get errorPdfGeneration;

  /// No description provided for @errorImagePick.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب عکس انجام نشد.'**
  String get errorImagePick;

  /// No description provided for @errorStorageRead.
  ///
  /// In fa, this message translates to:
  /// **'خواندن اطلاعات ذخیره‌شده ممکن نشد.'**
  String get errorStorageRead;

  /// No description provided for @errorStorageWrite.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره اطلاعات ممکن نشد.'**
  String get errorStorageWrite;

  /// No description provided for @errorShare.
  ///
  /// In fa, this message translates to:
  /// **'اشتراک‌گذاری فایل انجام نشد.'**
  String get errorShare;

  /// No description provided for @errorResumeNotFound.
  ///
  /// In fa, this message translates to:
  /// **'این رزومه پیدا نشد.'**
  String get errorResumeNotFound;

  /// No description provided for @errorTranslationDownload.
  ///
  /// In fa, this message translates to:
  /// **'دانلود بسته زبانی انجام نشد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.'**
  String get errorTranslationDownload;

  /// No description provided for @errorTranslationFailed.
  ///
  /// In fa, this message translates to:
  /// **'ترجمه انجام نشد. لطفاً دوباره تلاش کنید.'**
  String get errorTranslationFailed;

  /// No description provided for @errorBackupImport.
  ///
  /// In fa, this message translates to:
  /// **'این فایل یک پشتیبان رزومه‌یار نیست یا خوانده نشد.'**
  String get errorBackupImport;

  /// No description provided for @backupExport.
  ///
  /// In fa, this message translates to:
  /// **'خروجی اکسل'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی از فایل اکسل'**
  String get backupImport;

  /// No description provided for @backupExported.
  ///
  /// In fa, this message translates to:
  /// **'فایل اکسل ساخته شد'**
  String get backupExported;

  /// No description provided for @backupImported.
  ///
  /// In fa, this message translates to:
  /// **'رزومه از فایل بازیابی شد'**
  String get backupImported;

  /// No description provided for @backupPhotoNote.
  ///
  /// In fa, this message translates to:
  /// **'عکس پروفایل در فایل اکسل ذخیره نمی‌شود و پس از بازیابی باید دوباره اضافه شود.'**
  String get backupPhotoNote;

  /// No description provided for @adsLabel.
  ///
  /// In fa, this message translates to:
  /// **'تبلیغ'**
  String get adsLabel;

  /// No description provided for @adsLoadFailed.
  ///
  /// In fa, this message translates to:
  /// **'دریافت تبلیغات ناموفق بود'**
  String get adsLoadFailed;

  /// No description provided for @adsOpenFailed.
  ///
  /// In fa, this message translates to:
  /// **'باز کردن لینک ممکن نشد.'**
  String get adsOpenFailed;

  /// No description provided for @adsNotConfigured.
  ///
  /// In fa, this message translates to:
  /// **'امکان ارسال در این نسخه فعال نیست.'**
  String get adsNotConfigured;

  /// No description provided for @adsInvalidInput.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات واردشده معتبر نیست؛ فیلدها را بررسی کنید.'**
  String get adsInvalidInput;

  /// No description provided for @adsUnauthorized.
  ///
  /// In fa, this message translates to:
  /// **'ارتباط امن برنامه با سرور تأیید نشد؛ نسخه برنامه را به‌روزرسانی کنید.'**
  String get adsUnauthorized;

  /// No description provided for @adsRateLimited.
  ///
  /// In fa, this message translates to:
  /// **'تعداد درخواست‌ها زیاد است؛ کمی بعد دوباره تلاش کنید.'**
  String get adsRateLimited;

  /// No description provided for @adsNetwork.
  ///
  /// In fa, this message translates to:
  /// **'اتصال اینترنت را بررسی و دوباره تلاش کنید.'**
  String get adsNetwork;

  /// No description provided for @adsInvalidResponse.
  ///
  /// In fa, this message translates to:
  /// **'پاسخ سرور معتبر نیست؛ دوباره تلاش کنید.'**
  String get adsInvalidResponse;

  /// No description provided for @adsServer.
  ///
  /// In fa, this message translates to:
  /// **'مشکلی در سرور پیش آمد؛ کمی بعد دوباره تلاش کنید.'**
  String get adsServer;

  /// No description provided for @errorReportTitle.
  ///
  /// In fa, this message translates to:
  /// **'ارسال گزارش خطا'**
  String get errorReportTitle;

  /// No description provided for @errorReportIntro.
  ///
  /// In fa, this message translates to:
  /// **'اگر در برنامه به مشکلی برخوردید، لطفاً بنویسید در کدام صفحه بودید، چه کاری انجام دادید، چه نتیجه‌ای دیدید و انتظار چه نتیجه‌ای داشتید.'**
  String get errorReportIntro;

  /// No description provided for @errorReportDescription.
  ///
  /// In fa, this message translates to:
  /// **'شرح خطا'**
  String get errorReportDescription;

  /// No description provided for @errorReportHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: در صفحه پیش‌نمایش، هنگام گرفتن خروجی PDF...'**
  String get errorReportHint;

  /// No description provided for @errorReportTooShort.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً شرح خطا را کامل‌تر بنویسید (حداقل ۵ کاراکتر).'**
  String get errorReportTooShort;

  /// No description provided for @errorReportSubmit.
  ///
  /// In fa, this message translates to:
  /// **'ارسال گزارش'**
  String get errorReportSubmit;

  /// No description provided for @errorReportSent.
  ///
  /// In fa, this message translates to:
  /// **'گزارش شما ثبت شد'**
  String get errorReportSent;

  /// No description provided for @advertisingRequestTitle.
  ///
  /// In fa, this message translates to:
  /// **'درخواست تبلیغ'**
  String get advertisingRequestTitle;

  /// No description provided for @advertisingFullName.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی'**
  String get advertisingFullName;

  /// No description provided for @advertisingFullNameInvalid.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی را کامل وارد کنید.'**
  String get advertisingFullNameInvalid;

  /// No description provided for @advertisingPhone.
  ///
  /// In fa, this message translates to:
  /// **'شماره تماس'**
  String get advertisingPhone;

  /// No description provided for @advertisingPhoneInvalid.
  ///
  /// In fa, this message translates to:
  /// **'شماره تماس معتبر نیست.'**
  String get advertisingPhoneInvalid;

  /// No description provided for @advertisingProvince.
  ///
  /// In fa, this message translates to:
  /// **'استان'**
  String get advertisingProvince;

  /// No description provided for @advertisingCity.
  ///
  /// In fa, this message translates to:
  /// **'شهر'**
  String get advertisingCity;

  /// No description provided for @advertisingRegionInvalid.
  ///
  /// In fa, this message translates to:
  /// **'این فیلد را کامل وارد کنید.'**
  String get advertisingRegionInvalid;

  /// No description provided for @advertisingDetails.
  ///
  /// In fa, this message translates to:
  /// **'توضیحات تکمیلی'**
  String get advertisingDetails;

  /// No description provided for @advertisingSubmit.
  ///
  /// In fa, this message translates to:
  /// **'ثبت درخواست'**
  String get advertisingSubmit;

  /// No description provided for @advertisingSent.
  ///
  /// In fa, this message translates to:
  /// **'درخواست شما ثبت شد'**
  String get advertisingSent;

  /// No description provided for @advertisingRequestSent.
  ///
  /// In fa, this message translates to:
  /// **'درخواست شما ثبت شد؛ کارشناسان تبلیغات با شماره واردشده تماس می‌گیرند.'**
  String get advertisingRequestSent;

  /// No description provided for @advertisingPrivacy.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات شما فقط برای پیگیری همین درخواست استفاده می‌شود.'**
  String get advertisingPrivacy;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
