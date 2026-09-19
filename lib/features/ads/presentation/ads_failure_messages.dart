import '../../../core/l10n/l10n.dart';
import '../domain/ads_failure.dart';

extension AdsFailureMessage on AdsFailureKind {
  /// Server-side detail is never surfaced — only the category maps to text.
  String message(AppLocalizations l10n) => switch (this) {
    AdsFailureKind.notConfigured => l10n.adsNotConfigured,
    AdsFailureKind.invalidInput => l10n.adsInvalidInput,
    AdsFailureKind.unauthorized => l10n.adsUnauthorized,
    AdsFailureKind.rateLimited => l10n.adsRateLimited,
    AdsFailureKind.network => l10n.adsNetwork,
    AdsFailureKind.invalidResponse => l10n.adsInvalidResponse,
    AdsFailureKind.server => l10n.adsServer,
  };
}
