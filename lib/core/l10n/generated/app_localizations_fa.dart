// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'رزومه یار پارسیک';

  @override
  String get appTagline => 'رزومه حرفه‌ای، فرصت بهتر';

  @override
  String get splashSubtitle => 'رزومه حرفه‌ای خودت را بساز';

  @override
  String get commonSave => 'ذخیره';

  @override
  String get commonSaveAndClose => 'ذخیره و بستن';

  @override
  String get commonCancel => 'انصراف';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'ویرایش';

  @override
  String get commonAdd => 'افزودن';

  @override
  String get commonNext => 'بعدی';

  @override
  String get commonBack => 'قبلی';

  @override
  String get commonDone => 'پایان';

  @override
  String get commonClose => 'بستن';

  @override
  String get commonConfirm => 'تأیید';

  @override
  String get commonRetry => 'تلاش دوباره';

  @override
  String get commonOptional => 'اختیاری';

  @override
  String get commonPreview => 'پیش‌نمایش';

  @override
  String get commonShare => 'اشتراک‌گذاری';

  @override
  String get commonDuplicate => 'تهیه کپی';

  @override
  String get commonRemove => 'حذف';

  @override
  String get commonMore => 'بیشتر';

  @override
  String get commonSelect => 'انتخاب';

  @override
  String get commonClear => 'پاک کردن';

  @override
  String get homeTitle => 'رزومه‌های من';

  @override
  String get homeEmptyTitle => 'هنوز رزومه‌ای نساخته‌اید';

  @override
  String get homeEmptySubtitle => 'اولین رزومه حرفه‌ای خود را بسازید';

  @override
  String get homeCreateCta => 'ساخت رزومه جدید';

  @override
  String homeLastEdited(String date) {
    return 'آخرین ویرایش: $date';
  }

  @override
  String get homeSampleBadge => 'نمونه رزومه';

  @override
  String get homeDeleteTitle => 'حذف رزومه';

  @override
  String homeDeleteMessage(String title) {
    return 'رزومه «$title» حذف شود؟ این کار قابل بازگشت نیست.';
  }

  @override
  String get homeDeleted => 'رزومه حذف شد';

  @override
  String get homeDuplicated => 'کپی رزومه ساخته شد';

  @override
  String get homeCopySuffix => 'کپی';

  @override
  String get homeNewResumeTitle => 'رزومه جدید';

  @override
  String get homeCreateSheetTitle => 'ساخت رزومه جدید';

  @override
  String get homeCreateSheetLanguage => 'زبان رزومه';

  @override
  String get homeCreateSheetName => 'نام رزومه';

  @override
  String get homeCreateSheetNameHint => 'مثلاً: رزومه توسعه‌دهنده موبایل';

  @override
  String get homeRename => 'تغییر نام';

  @override
  String get favoriteAdd => 'افزودن به موردعلاقه‌ها';

  @override
  String get favoriteRemove => 'حذف از موردعلاقه‌ها';

  @override
  String get filterAll => 'همه';

  @override
  String get filterFavorites => 'ستاره‌دار';

  @override
  String get filterEmpty => 'رزومه‌ای با این فیلتر پیدا نشد';

  @override
  String get filterShowAll => 'نمایش همه';

  @override
  String get homeRenameTitle => 'تغییر نام رزومه';

  @override
  String get resumeLanguagePersian => 'فارسی';

  @override
  String get resumeLanguageEnglish => 'انگلیسی';

  @override
  String get resumeLanguageArabic => 'عربی';

  @override
  String get resumeLanguageLabel => 'زبان رزومه';

  @override
  String get translateTitle => 'ترجمه رزومه';

  @override
  String get translateTo => 'ترجمه به';

  @override
  String get translateAction => 'شروع ترجمه';

  @override
  String get translateWarning =>
      'ترجمه ماشینی است و ممکن است اشتباه داشته باشد. پیش از ارسال رزومه، متن ترجمه‌شده را بازبینی کنید.';

  @override
  String get translateArabicWarning =>
      'کیفیت ترجمه عربی برای جمله‌های کامل خوب است، اما عنوان‌های شغلی و عبارت‌های کوتاه اغلب نیاز به اصلاح دارند.';

  @override
  String get translateOfflineNote =>
      'ترجمه روی همین دستگاه انجام می‌شود و متن رزومه شما به هیچ سروری ارسال نمی‌شود.';

  @override
  String get translateModelNeeded =>
      'برای این زبان باید یک‌بار بسته زبانی دانلود شود (حدود ۳۰ مگابایت). پس از آن ترجمه بدون اینترنت کار می‌کند.';

  @override
  String get translateModelReady =>
      'بسته زبانی روی دستگاه موجود است. نیازی به اینترنت نیست.';

  @override
  String get translateDownloading => 'در حال دانلود بسته زبانی...';

  @override
  String get translateWorking => 'در حال ترجمه...';

  @override
  String translateProgress(int done, int total) {
    return '$done از $total';
  }

  @override
  String get translateDone => 'رزومه ترجمه‌شده ساخته شد';

  @override
  String translateNewTitle(String title, String language) {
    return '$title ($language)';
  }

  @override
  String get stepPersonalInfo => 'اطلاعات شخصی';

  @override
  String get stepSummary => 'درباره من';

  @override
  String get stepExperience => 'سوابق کاری';

  @override
  String get stepEducation => 'تحصیلات';

  @override
  String get stepSkills => 'مهارت‌ها';

  @override
  String get stepLanguages => 'زبان‌ها';

  @override
  String get stepProjects => 'پروژه‌ها';

  @override
  String get stepCertifications => 'دوره‌ها و گواهینامه‌ها';

  @override
  String get stepLinks => 'لینک‌ها';

  @override
  String get stepTemplate => 'انتخاب قالب';

  @override
  String get stepPreview => 'پیش‌نمایش';

  @override
  String stepProgress(int current, int total) {
    return 'گام $current از $total';
  }

  @override
  String get fieldFirstName => 'نام';

  @override
  String get fieldLastName => 'نام خانوادگی';

  @override
  String get fieldJobTitle => 'عنوان شغلی';

  @override
  String get fieldJobTitleHint => 'مثلاً: توسعه‌دهنده ارشد نرم‌افزار';

  @override
  String get fieldPhoto => 'عکس پروفایل';

  @override
  String get fieldMobile => 'شماره موبایل';

  @override
  String get fieldEmail => 'ایمیل';

  @override
  String get fieldCity => 'شهر';

  @override
  String get fieldCountry => 'کشور';

  @override
  String get fieldBirthDate => 'تاریخ تولد';

  @override
  String get fieldAddress => 'آدرس';

  @override
  String get fieldMaritalStatus => 'وضعیت تأهل';

  @override
  String get maritalSingle => 'مجرد';

  @override
  String get maritalMarried => 'متأهل';

  @override
  String get photoAdd => 'افزودن عکس';

  @override
  String get photoChange => 'تغییر عکس';

  @override
  String get photoFromCamera => 'دوربین';

  @override
  String get photoFromGallery => 'انتخاب از گالری';

  @override
  String get photoRemove => 'حذف عکس';

  @override
  String get optionalFieldsTitle => 'نمایش در رزومه';

  @override
  String get optionalFieldsSubtitle =>
      'مشخص کنید کدام اطلاعات اختیاری در رزومه نهایی دیده شوند.';

  @override
  String get summaryTitle => 'خلاصه حرفه‌ای';

  @override
  String get summaryHint =>
      'خلاصه‌ای کوتاه درباره تجربه، تخصص و اهداف حرفه‌ای خود بنویسید...';

  @override
  String get summaryRecommendation =>
      'پیشنهاد می‌شود بین ۳۰۰ تا ۶۰۰ کاراکتر بنویسید.';

  @override
  String summaryCharCount(int count) {
    return '$count کاراکتر';
  }

  @override
  String get fieldCompany => 'نام شرکت';

  @override
  String get fieldStartDate => 'تاریخ شروع';

  @override
  String get fieldEndDate => 'تاریخ پایان';

  @override
  String get fieldCurrentlyWorking => 'هم‌اکنون در اینجا مشغول به کار هستم';

  @override
  String get fieldDescription => 'توضیحات';

  @override
  String get fieldAchievements => 'دستاوردها';

  @override
  String get fieldAchievementsHint => 'هر دستاورد را در یک خط بنویسید.';

  @override
  String get dateNow => 'تاکنون';

  @override
  String get fieldDegree => 'مقطع تحصیلی';

  @override
  String get fieldFieldOfStudy => 'رشته تحصیلی';

  @override
  String get fieldInstitution => 'دانشگاه / مؤسسه';

  @override
  String get fieldSkillName => 'نام مهارت';

  @override
  String get fieldSkillLevel => 'سطح مهارت';

  @override
  String get skillLevelBeginner => 'مقدماتی';

  @override
  String get skillLevelIntermediate => 'متوسط';

  @override
  String get skillLevelAdvanced => 'پیشرفته';

  @override
  String get skillLevelExpert => 'حرفه‌ای';

  @override
  String get skillsShowLevels => 'نمایش سطح مهارت در رزومه';

  @override
  String get skillAddHint => 'نام مهارت را بنویسید و افزودن را بزنید';

  @override
  String get fieldLanguageName => 'نام زبان';

  @override
  String get fieldLanguageLevel => 'سطح تسلط';

  @override
  String get langLevelBasic => 'مقدماتی';

  @override
  String get langLevelIntermediate => 'متوسط';

  @override
  String get langLevelProfessional => 'پیشرفته';

  @override
  String get langLevelFluent => 'مسلط';

  @override
  String get langLevelNative => 'زبان مادری';

  @override
  String get fieldProjectName => 'نام پروژه';

  @override
  String get fieldRole => 'نقش شما';

  @override
  String get fieldTechnologies => 'تکنولوژی‌ها';

  @override
  String get fieldTechnologiesHint => 'مثلاً: Flutter، Firebase، REST API';

  @override
  String get fieldProjectUrl => 'لینک پروژه';

  @override
  String get fieldCertificateName => 'نام دوره یا گواهینامه';

  @override
  String get fieldOrganization => 'مؤسسه صادرکننده';

  @override
  String get fieldIssueDate => 'تاریخ دریافت';

  @override
  String get fieldCredentialUrl => 'لینک گواهینامه';

  @override
  String get fieldLinkTitle => 'عنوان';

  @override
  String get fieldLinkUrl => 'آدرس';

  @override
  String get linkTypeLinkedin => 'لینکدین';

  @override
  String get linkTypeGithub => 'گیت‌هاب';

  @override
  String get linkTypePortfolio => 'نمونه‌کارها';

  @override
  String get linkTypeWebsite => 'وب‌سایت';

  @override
  String get linkTypeTelegram => 'تلگرام';

  @override
  String get linkTypeOther => 'سایر';

  @override
  String get linkTypeLabel => 'نوع لینک';

  @override
  String get emptyExperience => 'هنوز سابقه کاری اضافه نکرده‌اید';

  @override
  String get emptyEducation => 'هنوز سابقه تحصیلی اضافه نکرده‌اید';

  @override
  String get emptySkills => 'هنوز مهارتی اضافه نکرده‌اید';

  @override
  String get emptyLanguages => 'هنوز زبانی اضافه نکرده‌اید';

  @override
  String get emptyProjects => 'هنوز پروژه‌ای اضافه نکرده‌اید';

  @override
  String get emptyCertifications => 'هنوز دوره یا گواهینامه‌ای اضافه نکرده‌اید';

  @override
  String get emptyLinks => 'هنوز لینکی اضافه نکرده‌اید';

  @override
  String get emptySectionHint =>
      'این بخش اختیاری است و در صورت خالی بودن در رزومه نمایش داده نمی‌شود.';

  @override
  String get addExperience => 'افزودن سابقه کاری';

  @override
  String get addEducation => 'افزودن تحصیلات';

  @override
  String get addSkill => 'افزودن مهارت';

  @override
  String get addLanguage => 'افزودن زبان';

  @override
  String get addProject => 'افزودن پروژه';

  @override
  String get addCertification => 'افزودن دوره یا گواهینامه';

  @override
  String get addLink => 'افزودن لینک';

  @override
  String get editExperience => 'ویرایش سابقه کاری';

  @override
  String get editEducation => 'ویرایش تحصیلات';

  @override
  String get editSkill => 'ویرایش مهارت';

  @override
  String get editLanguage => 'ویرایش زبان';

  @override
  String get editProject => 'ویرایش پروژه';

  @override
  String get editCertification => 'ویرایش دوره یا گواهینامه';

  @override
  String get editLink => 'ویرایش لینک';

  @override
  String get reorderHint => 'برای جابه‌جایی، آیتم را بکشید و رها کنید.';

  @override
  String get deleteItemTitle => 'حذف آیتم';

  @override
  String get deleteItemMessage => 'این مورد حذف شود؟';

  @override
  String get templatesTitle => 'قالب‌ها';

  @override
  String get templateClassic => 'کلاسیک';

  @override
  String get templateClassicDesc => 'ساده و رسمی، مناسب مشاغل سازمانی و اداری';

  @override
  String get templateModern => 'مدرن';

  @override
  String get templateModernDesc =>
      'دو ستونی با ستون کناری مهارت‌ها و عکس پروفایل';

  @override
  String get templateMinimal => 'مینیمال';

  @override
  String get templateMinimalDesc =>
      'بسیار تمیز با فضای سفید زیاد و تمرکز بر تایپوگرافی';

  @override
  String get templateProBadge => 'ویژه';

  @override
  String get customizeTitle => 'شخصی‌سازی';

  @override
  String get customizeAccent => 'رنگ اصلی';

  @override
  String get customizeShowPhoto => 'نمایش عکس پروفایل';

  @override
  String get customizeShowPhotoDisabled =>
      'این قالب از عکس پروفایل پشتیبانی نمی‌کند';

  @override
  String get customizeFontSize => 'اندازه فونت';

  @override
  String get fontSizeSmall => 'کوچک';

  @override
  String get fontSizeNormal => 'معمولی';

  @override
  String get fontSizeLarge => 'بزرگ';

  @override
  String get previewTitle => 'پیش‌نمایش رزومه';

  @override
  String get previewExport => 'خروجی PDF';

  @override
  String get previewShare => 'اشتراک‌گذاری';

  @override
  String get previewGenerating => 'در حال ساخت فایل PDF...';

  @override
  String get previewSaved => 'فایل PDF ذخیره شد';

  @override
  String previewSavedAt(String path) {
    return 'فایل در $path ذخیره شد';
  }

  @override
  String get previewChangeTemplate => 'تغییر قالب';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsSectionGeneral => 'عمومی';

  @override
  String get settingsSectionAbout => 'درباره';

  @override
  String get settingsAppLanguage => 'زبان برنامه';

  @override
  String get settingsTheme => 'پوسته';

  @override
  String get themeSystem => 'پیش‌فرض سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get settingsDefaultResumeLanguage => 'زبان پیش‌فرض رزومه';

  @override
  String get settingsAbout => 'درباره رزومه‌یار';

  @override
  String get settingsPrivacy => 'حریم خصوصی';

  @override
  String settingsVersion(String version) {
    return 'نسخه $version';
  }

  @override
  String get privacyTitle => 'حریم خصوصی';

  @override
  String get privacyLocalStorage =>
      'اطلاعات رزومه شما روی دستگاه ذخیره می‌شود.';

  @override
  String get privacyBody =>
      'رزومه‌یار هیچ اطلاعاتی را به سرور ارسال نمی‌کند. تمام رزومه‌ها، عکس‌ها و تنظیمات فقط روی همین دستگاه نگهداری می‌شوند و با حذف برنامه، این اطلاعات نیز پاک می‌شوند.';

  @override
  String get privacyNoAccount =>
      'برای استفاده از برنامه نیازی به ثبت‌نام یا ورود نیست.';

  @override
  String get privacyNoInternet =>
      'برنامه برای ساخت، ویرایش و خروجی گرفتن از رزومه به اینترنت نیاز ندارد.';

  @override
  String get privacyTranslation =>
      'ترجمه رزومه روی همین دستگاه انجام می‌شود و متن رزومه شما به هیچ سروری ارسال نمی‌شود. تنها موردی که به اینترنت نیاز دارد، دانلود یک‌باره بسته زبانی برای هر زبان است.';

  @override
  String get privacyPermissions =>
      'دسترسی به دوربین و گالری تنها زمانی استفاده می‌شود که خودتان بخواهید عکس پروفایل اضافه کنید.';

  @override
  String get aboutTitle => 'درباره رزومه‌یار';

  @override
  String get aboutBody =>
      'رزومه‌یار به شما کمک می‌کند در چند دقیقه یک رزومه حرفه‌ای فارسی یا انگلیسی بسازید و آن را به صورت فایل PDF با کیفیت ذخیره یا ارسال کنید.';

  @override
  String get validationRequired => 'این فیلد الزامی است';

  @override
  String get validationInvalidEmail => 'ایمیل معتبر نیست';

  @override
  String get validationInvalidUrl => 'آدرس اینترنتی معتبر نیست';

  @override
  String get validationFirstNameRequired => 'لطفاً نام را وارد کنید';

  @override
  String get validationLastNameRequired => 'لطفاً نام خانوادگی را وارد کنید';

  @override
  String get validationEndBeforeStart =>
      'تاریخ پایان نمی‌تواند قبل از تاریخ شروع باشد';

  @override
  String get errorGeneric => 'مشکلی پیش آمد. لطفاً دوباره تلاش کنید.';

  @override
  String get errorPdfGeneration =>
      'ساخت فایل PDF انجام نشد. لطفاً دوباره تلاش کنید.';

  @override
  String get errorImagePick => 'انتخاب عکس انجام نشد.';

  @override
  String get errorStorageRead => 'خواندن اطلاعات ذخیره‌شده ممکن نشد.';

  @override
  String get errorStorageWrite => 'ذخیره اطلاعات ممکن نشد.';

  @override
  String get errorShare => 'اشتراک‌گذاری فایل انجام نشد.';

  @override
  String get errorResumeNotFound => 'این رزومه پیدا نشد.';

  @override
  String get errorTranslationDownload =>
      'دانلود بسته زبانی انجام نشد. اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get errorTranslationFailed =>
      'ترجمه انجام نشد. لطفاً دوباره تلاش کنید.';

  @override
  String get errorBackupImport =>
      'این فایل یک پشتیبان رزومه‌یار نیست یا خوانده نشد.';

  @override
  String get backupExport => 'خروجی اکسل';

  @override
  String get backupImport => 'بازیابی از فایل اکسل';

  @override
  String get backupExported => 'فایل اکسل ساخته شد';

  @override
  String get backupImported => 'رزومه از فایل بازیابی شد';

  @override
  String get backupPhotoNote =>
      'عکس پروفایل در فایل اکسل ذخیره نمی‌شود و پس از بازیابی باید دوباره اضافه شود.';

  @override
  String get adsLabel => 'تبلیغ';

  @override
  String get adsLoadFailed => 'دریافت تبلیغات ناموفق بود';

  @override
  String get adsOpenFailed => 'باز کردن لینک ممکن نشد.';

  @override
  String get adsNotConfigured => 'امکان ارسال در این نسخه فعال نیست.';

  @override
  String get adsInvalidInput =>
      'اطلاعات واردشده معتبر نیست؛ فیلدها را بررسی کنید.';

  @override
  String get adsUnauthorized =>
      'ارتباط امن برنامه با سرور تأیید نشد؛ نسخه برنامه را به‌روزرسانی کنید.';

  @override
  String get adsRateLimited =>
      'تعداد درخواست‌ها زیاد است؛ کمی بعد دوباره تلاش کنید.';

  @override
  String get adsNetwork => 'اتصال اینترنت را بررسی و دوباره تلاش کنید.';

  @override
  String get adsInvalidResponse => 'پاسخ سرور معتبر نیست؛ دوباره تلاش کنید.';

  @override
  String get adsServer => 'مشکلی در سرور پیش آمد؛ کمی بعد دوباره تلاش کنید.';

  @override
  String get errorReportTitle => 'ارسال گزارش خطا';

  @override
  String get errorReportIntro =>
      'اگر در برنامه به مشکلی برخوردید، لطفاً بنویسید در کدام صفحه بودید، چه کاری انجام دادید، چه نتیجه‌ای دیدید و انتظار چه نتیجه‌ای داشتید.';

  @override
  String get errorReportDescription => 'شرح خطا';

  @override
  String get errorReportHint =>
      'مثلاً: در صفحه پیش‌نمایش، هنگام گرفتن خروجی PDF...';

  @override
  String get errorReportTooShort =>
      'لطفاً شرح خطا را کامل‌تر بنویسید (حداقل ۵ کاراکتر).';

  @override
  String get errorReportSubmit => 'ارسال گزارش';

  @override
  String get errorReportSent => 'گزارش شما ثبت شد';

  @override
  String get advertisingRequestTitle => 'درخواست تبلیغ';

  @override
  String get advertisingFullName => 'نام و نام خانوادگی';

  @override
  String get advertisingFullNameInvalid =>
      'نام و نام خانوادگی را کامل وارد کنید.';

  @override
  String get advertisingPhone => 'شماره تماس';

  @override
  String get advertisingPhoneInvalid => 'شماره تماس معتبر نیست.';

  @override
  String get advertisingProvince => 'استان';

  @override
  String get advertisingCity => 'شهر';

  @override
  String get advertisingRegionInvalid => 'این فیلد را کامل وارد کنید.';

  @override
  String get advertisingDetails => 'توضیحات تکمیلی';

  @override
  String get advertisingSubmit => 'ثبت درخواست';

  @override
  String get advertisingSent => 'درخواست شما ثبت شد';

  @override
  String get advertisingRequestSent =>
      'درخواست شما ثبت شد؛ کارشناسان تبلیغات با شماره واردشده تماس می‌گیرند.';

  @override
  String get advertisingPrivacy =>
      'اطلاعات شما فقط برای پیگیری همین درخواست استفاده می‌شود.';
}
