import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Shorthand for [AppLocalizations.of] — `context.l10n.homeTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

abstract final class AppLocales {
  static const Locale persian = Locale('fa');
  static const Locale english = Locale('en');

  static const List<Locale> supported = <Locale>[persian, english];

  static Locale fromCode(String? code) =>
      code == 'en' ? english : persian;
}
