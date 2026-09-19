import 'ad_models.dart';

/// Banner fetching and click registration.
///
/// The UI depends on this, never on the HTTP layer, so widget tests can run
/// against a fake without touching a socket.
abstract interface class AdvertisingGateway {
  /// False when the build carries no API keys; callers must then show nothing
  /// rather than an error or a placeholder ad.
  bool get isConfigured;

  /// Resolves an API-relative asset path to an absolute, scheme-checked URL.
  /// Returns null for anything unsafe to open or load.
  Uri? resolvePublicUrl(String? value);

  Future<List<AdBannerModel>> fetchBanners();

  /// Registers a click and returns the destination the API wants opened.
  Future<AdClickReceipt> registerClick({
    required String bannerId,
    required String externalUserId,
  });

  void close();
}

/// Submission of the error-report and advertising-request forms.
abstract interface class AppSupportGateway {
  bool get isConfigured;

  Future<SubmissionReceipt> submitErrorReport({required String description});

  Future<SubmissionReceipt> submitAdvertisingRequest({
    required String fullName,
    required String phoneNumber,
    required String province,
    required String city,
    required String details,
  });

  void close();
}
