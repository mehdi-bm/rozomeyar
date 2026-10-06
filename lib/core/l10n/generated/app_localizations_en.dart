// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ResumeYar';

  @override
  String get appTagline => 'A professional resume, a better opportunity';

  @override
  String get splashSubtitle => 'Build your professional resume';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveAndClose => 'Save & close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonPreview => 'Preview';

  @override
  String get commonShare => 'Share';

  @override
  String get commonDuplicate => 'Duplicate';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonMore => 'More';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonClear => 'Clear';

  @override
  String get homeTitle => 'My resumes';

  @override
  String get homeEmptyTitle => 'You haven\'t created a resume yet';

  @override
  String get homeEmptySubtitle => 'Build your first professional resume';

  @override
  String get homeCreateCta => 'Create new resume';

  @override
  String homeLastEdited(String date) {
    return 'Last edited: $date';
  }

  @override
  String get homeSampleBadge => 'Sample resume';

  @override
  String get homeDeleteTitle => 'Delete resume';

  @override
  String homeDeleteMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get homeDeleted => 'Resume deleted';

  @override
  String get homeDuplicated => 'Resume duplicated';

  @override
  String get homeCopySuffix => 'copy';

  @override
  String get homeNewResumeTitle => 'New resume';

  @override
  String get homeCreateSheetTitle => 'Create new resume';

  @override
  String get homeCreateSheetLanguage => 'Resume language';

  @override
  String get homeCreateSheetName => 'Resume name';

  @override
  String get homeCreateSheetNameHint => 'e.g. Mobile Developer Resume';

  @override
  String get homeRename => 'Rename';

  @override
  String get favoriteAdd => 'Add to favourites';

  @override
  String get favoriteRemove => 'Remove from favourites';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorites => 'Starred';

  @override
  String get filterEmpty => 'No resumes match this filter';

  @override
  String get filterShowAll => 'Show all';

  @override
  String get homeRenameTitle => 'Rename resume';

  @override
  String get resumeLanguagePersian => 'Persian';

  @override
  String get resumeLanguageEnglish => 'English';

  @override
  String get resumeLanguageArabic => 'Arabic';

  @override
  String get resumeLanguageLabel => 'Resume language';

  @override
  String get translateTitle => 'Translate resume';

  @override
  String get translateTo => 'Translate to';

  @override
  String get translateAction => 'Start translation';

  @override
  String get translateWarning =>
      'This is a machine translation and may contain mistakes. Review the result before sending your resume anywhere.';

  @override
  String get translateArabicWarning =>
      'Arabic output is good for full sentences, but job titles and short phrases often need correcting.';

  @override
  String get translateOfflineNote =>
      'Translation runs on this device — your resume text is never sent to any server.';

  @override
  String get translateModelNeeded =>
      'This language needs a one-off language pack download (about 30 MB). After that, translation works without an internet connection.';

  @override
  String get translateModelReady =>
      'The language pack is already on this device. No internet needed.';

  @override
  String get translateDownloading => 'Downloading language pack...';

  @override
  String get translateWorking => 'Translating...';

  @override
  String translateProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get translateDone => 'Translated resume created';

  @override
  String translateNewTitle(String title, String language) {
    return '$title ($language)';
  }

  @override
  String get stepPersonalInfo => 'Personal information';

  @override
  String get stepSummary => 'About me';

  @override
  String get stepExperience => 'Work experience';

  @override
  String get stepEducation => 'Education';

  @override
  String get stepSkills => 'Skills';

  @override
  String get stepLanguages => 'Languages';

  @override
  String get stepProjects => 'Projects';

  @override
  String get stepCertifications => 'Courses & certifications';

  @override
  String get stepLinks => 'Links';

  @override
  String get stepTemplate => 'Template';

  @override
  String get stepPreview => 'Preview';

  @override
  String stepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldJobTitle => 'Job title';

  @override
  String get fieldJobTitleHint => 'e.g. Senior Software Developer';

  @override
  String get fieldPhoto => 'Profile photo';

  @override
  String get fieldMobile => 'Mobile number';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldBirthDate => 'Date of birth';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldMaritalStatus => 'Marital status';

  @override
  String get maritalSingle => 'Single';

  @override
  String get maritalMarried => 'Married';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoFromCamera => 'Camera';

  @override
  String get photoFromGallery => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get optionalFieldsTitle => 'Show in resume';

  @override
  String get optionalFieldsSubtitle =>
      'Choose which optional details appear in the final resume.';

  @override
  String get summaryTitle => 'Professional summary';

  @override
  String get summaryHint =>
      'Write a short summary of your experience, expertise and career goals...';

  @override
  String get summaryRecommendation => '300 to 600 characters works best.';

  @override
  String summaryCharCount(int count) {
    return '$count characters';
  }

  @override
  String get fieldCompany => 'Company';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get fieldEndDate => 'End date';

  @override
  String get fieldCurrentlyWorking => 'I currently work here';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldAchievements => 'Achievements';

  @override
  String get fieldAchievementsHint => 'Write one achievement per line.';

  @override
  String get dateNow => 'Present';

  @override
  String get fieldDegree => 'Degree';

  @override
  String get fieldFieldOfStudy => 'Field of study';

  @override
  String get fieldInstitution => 'University / Institute';

  @override
  String get fieldSkillName => 'Skill name';

  @override
  String get fieldSkillLevel => 'Proficiency';

  @override
  String get skillLevelBeginner => 'Beginner';

  @override
  String get skillLevelIntermediate => 'Intermediate';

  @override
  String get skillLevelAdvanced => 'Advanced';

  @override
  String get skillLevelExpert => 'Expert';

  @override
  String get skillsShowLevels => 'Show proficiency level in resume';

  @override
  String get skillAddHint => 'Type a skill name and tap Add';

  @override
  String get fieldLanguageName => 'Language';

  @override
  String get fieldLanguageLevel => 'Proficiency';

  @override
  String get langLevelBasic => 'Basic';

  @override
  String get langLevelIntermediate => 'Intermediate';

  @override
  String get langLevelProfessional => 'Professional';

  @override
  String get langLevelFluent => 'Fluent';

  @override
  String get langLevelNative => 'Native';

  @override
  String get fieldProjectName => 'Project name';

  @override
  String get fieldRole => 'Your role';

  @override
  String get fieldTechnologies => 'Technologies';

  @override
  String get fieldTechnologiesHint => 'e.g. Flutter, Firebase, REST API';

  @override
  String get fieldProjectUrl => 'Project URL';

  @override
  String get fieldCertificateName => 'Course / certificate name';

  @override
  String get fieldOrganization => 'Issuing organization';

  @override
  String get fieldIssueDate => 'Issue date';

  @override
  String get fieldCredentialUrl => 'Credential URL';

  @override
  String get fieldLinkTitle => 'Title';

  @override
  String get fieldLinkUrl => 'URL';

  @override
  String get linkTypeLinkedin => 'LinkedIn';

  @override
  String get linkTypeGithub => 'GitHub';

  @override
  String get linkTypePortfolio => 'Portfolio';

  @override
  String get linkTypeWebsite => 'Website';

  @override
  String get linkTypeTelegram => 'Telegram';

  @override
  String get linkTypeOther => 'Other';

  @override
  String get linkTypeLabel => 'Link type';

  @override
  String get emptyExperience => 'No work experience added yet';

  @override
  String get emptyEducation => 'No education added yet';

  @override
  String get emptySkills => 'No skills added yet';

  @override
  String get emptyLanguages => 'No languages added yet';

  @override
  String get emptyProjects => 'No projects added yet';

  @override
  String get emptyCertifications => 'No courses or certificates added yet';

  @override
  String get emptyLinks => 'No links added yet';

  @override
  String get emptySectionHint =>
      'This section is optional and is hidden from the resume when empty.';

  @override
  String get addExperience => 'Add work experience';

  @override
  String get addEducation => 'Add education';

  @override
  String get addSkill => 'Add skill';

  @override
  String get addLanguage => 'Add language';

  @override
  String get addProject => 'Add project';

  @override
  String get addCertification => 'Add course or certificate';

  @override
  String get addLink => 'Add link';

  @override
  String get editExperience => 'Edit work experience';

  @override
  String get editEducation => 'Edit education';

  @override
  String get editSkill => 'Edit skill';

  @override
  String get editLanguage => 'Edit language';

  @override
  String get editProject => 'Edit project';

  @override
  String get editCertification => 'Edit course or certificate';

  @override
  String get editLink => 'Edit link';

  @override
  String get reorderHint => 'Drag and drop to reorder.';

  @override
  String get deleteItemTitle => 'Delete item';

  @override
  String get deleteItemMessage => 'Delete this item?';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templateClassic => 'Classic';

  @override
  String get templateClassicDesc =>
      'Simple and formal, ideal for corporate roles';

  @override
  String get templateModern => 'Modern';

  @override
  String get templateModernDesc =>
      'Two-column layout with a skills sidebar and profile photo';

  @override
  String get templateMinimal => 'Minimal';

  @override
  String get templateMinimalDesc =>
      'Very clean, lots of whitespace, typography focused';

  @override
  String get templateProBadge => 'Pro';

  @override
  String get customizeTitle => 'Customize';

  @override
  String get customizeAccent => 'Accent color';

  @override
  String get customizeShowPhoto => 'Show profile photo';

  @override
  String get customizeShowPhotoDisabled =>
      'This template does not use a profile photo';

  @override
  String get customizeFontSize => 'Font size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get previewTitle => 'Resume preview';

  @override
  String get previewExport => 'Export PDF';

  @override
  String get previewShare => 'Share';

  @override
  String get previewGenerating => 'Generating PDF...';

  @override
  String get previewSaved => 'PDF saved';

  @override
  String previewSavedAt(String path) {
    return 'Saved to $path';
  }

  @override
  String get previewChangeTemplate => 'Change template';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsDefaultResumeLanguage => 'Default resume language';

  @override
  String get settingsAbout => 'About ResumeYar';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyLocalStorage =>
      'Your resume data is stored on your device.';

  @override
  String get privacyBody =>
      'ResumeYar never sends your data to a server. All resumes, photos and settings stay on this device, and removing the app deletes them too.';

  @override
  String get privacyNoAccount =>
      'No sign-up or login is required to use the app.';

  @override
  String get privacyNoInternet =>
      'The app does not need an internet connection to build, edit or export resumes.';

  @override
  String get privacyTranslation =>
      'Resume translation runs on this device and your resume text is never sent to any server. The only thing that needs the internet is a one-off language pack download per language.';

  @override
  String get privacyPermissions =>
      'Camera and gallery access is used only when you choose to add a profile photo.';

  @override
  String get aboutTitle => 'About ResumeYar';

  @override
  String get aboutBody =>
      'ResumeYar helps you build a professional Persian or English resume in minutes and export it as a high-quality PDF.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String get validationInvalidUrl => 'Enter a valid URL';

  @override
  String get validationFirstNameRequired => 'Please enter your first name';

  @override
  String get validationLastNameRequired => 'Please enter your last name';

  @override
  String get validationEndBeforeStart =>
      'The end date can\'t be before the start date';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorPdfGeneration =>
      'Could not generate the PDF. Please try again.';

  @override
  String get errorImagePick => 'Could not select the image.';

  @override
  String get errorStorageRead => 'Could not read saved data.';

  @override
  String get errorStorageWrite => 'Could not save your data.';

  @override
  String get errorShare => 'Could not share the file.';

  @override
  String get errorResumeNotFound => 'This resume could not be found.';

  @override
  String get errorTranslationDownload =>
      'Could not download the language pack. Check your internet connection and try again.';

  @override
  String get errorTranslationFailed => 'Translation failed. Please try again.';

  @override
  String get errorBackupImport =>
      'That file is not a ResumeYar backup, or could not be read.';

  @override
  String get backupExport => 'Export to Excel';

  @override
  String get backupImport => 'Restore from Excel file';

  @override
  String get backupExported => 'Excel file created';

  @override
  String get backupImported => 'Resume restored from file';

  @override
  String get backupPhotoNote =>
      'The profile photo is not stored in the Excel file and must be added again after restoring.';

  @override
  String get adsLabel => 'Ad';

  @override
  String get adsLoadFailed => 'Could not load ads';

  @override
  String get adsOpenFailed => 'Could not open the link.';

  @override
  String get adsNotConfigured => 'Sending is not available in this build.';

  @override
  String get adsInvalidInput =>
      'The information entered is not valid; please check the fields.';

  @override
  String get adsUnauthorized =>
      'The app could not be verified with the server; please update the app.';

  @override
  String get adsRateLimited => 'Too many requests; please try again shortly.';

  @override
  String get adsNetwork => 'Check your internet connection and try again.';

  @override
  String get adsInvalidResponse =>
      'The server response was not valid; please try again.';

  @override
  String get adsServer =>
      'Something went wrong on the server; please try again shortly.';

  @override
  String get errorReportTitle => 'Report a problem';

  @override
  String get errorReportIntro =>
      'If something went wrong, tell us which screen you were on, what you did, what happened, and what you expected instead.';

  @override
  String get errorReportDescription => 'What went wrong';

  @override
  String get errorReportHint =>
      'e.g. On the preview screen, while exporting a PDF...';

  @override
  String get errorReportTooShort =>
      'Please describe the problem in a little more detail (at least 5 characters).';

  @override
  String get errorReportSubmit => 'Send report';

  @override
  String get errorReportSent => 'Your report has been submitted';

  @override
  String get advertisingRequestTitle => 'Advertising request';

  @override
  String get advertisingFullName => 'Full name';

  @override
  String get advertisingFullNameInvalid => 'Please enter your full name.';

  @override
  String get advertisingPhone => 'Phone number';

  @override
  String get advertisingPhoneInvalid => 'That phone number is not valid.';

  @override
  String get advertisingProvince => 'Province';

  @override
  String get advertisingCity => 'City';

  @override
  String get advertisingRegionInvalid => 'Please complete this field.';

  @override
  String get advertisingDetails => 'Additional details';

  @override
  String get advertisingSubmit => 'Submit request';

  @override
  String get advertisingSent => 'Your request has been submitted';

  @override
  String get advertisingRequestSent =>
      'Your request has been submitted; our advertising team will call the number you provided.';

  @override
  String get advertisingPrivacy =>
      'Your information is used only to follow up on this request.';
}
