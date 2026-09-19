import '../models/app_settings.dart';
import '../models/enums.dart';

abstract interface class SettingsRepository {
  AppSettings get current;

  /// Emits on every change so the app can rebuild theme/locale reactively.
  Stream<AppSettings> watch();

  Future<void> setAppLanguageCode(String code);

  Future<void> setThemeMode(AppThemeMode mode);

  Future<void> setDefaultResumeLanguage(ResumeLanguage language);

  Future<void> markSampleSeeded();
}
