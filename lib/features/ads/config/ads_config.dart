import 'package:flutter/foundation.dart';

/// Parsik advertising configuration.
///
/// Every value comes from `--dart-define` at build time. **No key is ever
/// hard-coded, defaulted to a placeholder, logged, or written to an asset** —
/// if a key is missing the feature disables itself rather than inventing one,
/// so a misconfigured build fails visibly instead of sending garbage.
@immutable
class AdsConfig {
  const AdsConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.externalAppApiKey,
    required this.appName,
    required this.platform,
    required this.sectionCode,
    this.allowInsecureHttp = false,
  });

  /// Reads the configuration the build was compiled with.
  factory AdsConfig.fromEnvironment() {
    return const AdsConfig(
      baseUrl: String.fromEnvironment(
        'ADS_BASE_URL',
        defaultValue: 'https://ads.parsikonline.ir/',
      ),
      apiKey: String.fromEnvironment('ADS_API_KEY'),
      externalAppApiKey: String.fromEnvironment('ADS_EXTERNAL_APP_API_KEY'),
      appName: String.fromEnvironment(
        'ADS_APP_NAME',
        defaultValue: 'resumeyar',
      ),
      platform: String.fromEnvironment(
        'ADS_PLATFORM',
        defaultValue: 'Android',
      ),
      sectionCode: String.fromEnvironment('ADS_SECTION_CODE'),
      // Plain HTTP is only ever acceptable against a local dev server, and
      // only when the build explicitly opts in.
      allowInsecureHttp: bool.fromEnvironment('ADS_ALLOW_INSECURE_HTTP'),
    );
  }

  final String baseUrl;
  final String apiKey;
  final String externalAppApiKey;
  final String appName;
  final String platform;
  final String sectionCode;
  final bool allowInsecureHttp;

  /// True only when both keys are present. The UI must hide or disable every
  /// advertising feature when this is false.
  bool get isConfigured =>
      apiKey.trim().isNotEmpty &&
      externalAppApiKey.trim().isNotEmpty &&
      origin != null;

  /// The single origin that may receive the API keys. Any redirect away from
  /// it must drop them.
  Uri? get origin {
    final parsed = Uri.tryParse(baseUrl.trim());
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) return null;
    if (parsed.scheme == 'https') return parsed;
    if (parsed.scheme == 'http' && allowInsecureHttp) return parsed;
    return null;
  }

  bool isSameOrigin(Uri other) {
    final self = origin;
    if (self == null) return false;
    return other.scheme == self.scheme &&
        other.host == self.host &&
        other.port == self.port;
  }

  /// Resolves an API-relative path such as `/uploads/banners/x.webp` against
  /// the configured base, and rejects anything that is not safe to load.
  Uri? resolvePublicUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final self = origin;
    if (self == null) return null;

    Uri? candidate = Uri.tryParse(trimmed);
    if (candidate == null) return null;
    if (!candidate.hasScheme) candidate = self.resolveUri(candidate);

    if (candidate.host.isEmpty) return null;
    if (candidate.scheme == 'https') return candidate;
    if (candidate.scheme == 'http' && allowInsecureHttp) return candidate;
    // javascript:, file:, intent:, data: and friends never get through.
    return null;
  }

  @override
  String toString() =>
      'AdsConfig(baseUrl: $baseUrl, appName: $appName, '
      'platform: $platform, sectionCode: $sectionCode, '
      'configured: $isConfigured)';
}
