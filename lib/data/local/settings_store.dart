import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/enums.dart';

/// Thin `shared_preferences` wrapper. Settings are flat scalars, so they do not
/// warrant the JSON document store used for resumes.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kAppLanguage = 'settings.appLanguageCode';
  static const String _kThemeMode = 'settings.themeMode';
  static const String _kDefaultResumeLanguage = 'settings.defaultResumeLanguage';
  static const String _kSampleSeeded = 'settings.hasSeededSample';

  static Future<SettingsStore> open() async =>
      SettingsStore(await SharedPreferences.getInstance());

  AppSettings read() {
    return AppSettings(
      appLanguageCode: _prefs.getString(_kAppLanguage) ?? 'fa',
      themeMode: AppThemeMode.fromName(_prefs.getString(_kThemeMode)),
      defaultResumeLanguage: ResumeLanguage.fromName(
        _prefs.getString(_kDefaultResumeLanguage),
      ),
      hasSeededSample: _prefs.getBool(_kSampleSeeded) ?? false,
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setString(_kAppLanguage, settings.appLanguageCode);
    await _prefs.setString(_kThemeMode, settings.themeMode.name);
    await _prefs.setString(
      _kDefaultResumeLanguage,
      settings.defaultResumeLanguage.name,
    );
    await _prefs.setBool(_kSampleSeeded, settings.hasSeededSample);
  }
}
