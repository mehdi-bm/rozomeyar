import 'package:equatable/equatable.dart';

import 'enums.dart';

/// User preferences for the app itself. Resume-level options live in
/// `TemplateSettings` on each resume, not here.
class AppSettings extends Equatable {
  const AppSettings({
    this.appLanguageCode = 'fa',
    this.themeMode = AppThemeMode.system,
    this.defaultResumeLanguage = ResumeLanguage.persian,
    this.hasSeededSample = false,
  });

  final String appLanguageCode;
  final AppThemeMode themeMode;
  final ResumeLanguage defaultResumeLanguage;

  /// Whether the «نمونه رزومه» has already been created once, so it is never
  /// re-added after the user deletes it.
  final bool hasSeededSample;

  AppSettings copyWith({
    String? appLanguageCode,
    AppThemeMode? themeMode,
    ResumeLanguage? defaultResumeLanguage,
    bool? hasSeededSample,
  }) {
    return AppSettings(
      appLanguageCode: appLanguageCode ?? this.appLanguageCode,
      themeMode: themeMode ?? this.themeMode,
      defaultResumeLanguage:
          defaultResumeLanguage ?? this.defaultResumeLanguage,
      hasSeededSample: hasSeededSample ?? this.hasSeededSample,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    appLanguageCode,
    themeMode,
    defaultResumeLanguage,
    hasSeededSample,
  ];
}
