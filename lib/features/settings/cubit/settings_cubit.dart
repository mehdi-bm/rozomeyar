import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/app_settings.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/repositories/settings_repository.dart';

/// Owns app-wide preferences. Provided at the app root so theme and locale
/// changes rebuild `MaterialApp` immediately.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.current) {
    _subscription = _repository.watch().listen(emit);
  }

  final SettingsRepository _repository;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> setAppLanguage(String code) =>
      _repository.setAppLanguageCode(code);

  Future<void> setThemeMode(AppThemeMode mode) =>
      _repository.setThemeMode(mode);

  Future<void> setDefaultResumeLanguage(ResumeLanguage language) =>
      _repository.setDefaultResumeLanguage(language);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
