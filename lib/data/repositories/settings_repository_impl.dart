import 'dart:async';

import '../../domain/models/app_settings.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/settings_store.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store) : _settings = _store.read();

  final SettingsStore _store;
  final _controller = StreamController<AppSettings>.broadcast();

  AppSettings _settings;

  @override
  AppSettings get current => _settings;

  @override
  Stream<AppSettings> watch() async* {
    yield _settings;
    yield* _controller.stream;
  }

  Future<void> _update(AppSettings next) async {
    if (next == _settings) return;
    _settings = next;
    await _store.write(next);
    _controller.add(next);
  }

  @override
  Future<void> setAppLanguageCode(String code) =>
      _update(_settings.copyWith(appLanguageCode: code));

  @override
  Future<void> setThemeMode(AppThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  @override
  Future<void> setDefaultResumeLanguage(ResumeLanguage language) =>
      _update(_settings.copyWith(defaultResumeLanguage: language));

  @override
  Future<void> markSampleSeeded() =>
      _update(_settings.copyWith(hasSeededSample: true));

  Future<void> dispose() => _controller.close();
}
