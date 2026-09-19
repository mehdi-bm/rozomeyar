import '../config/ads_config.dart';
import '../domain/ad_models.dart';
import '../domain/advertising_gateway.dart';
import '../domain/ads_failure.dart';
import 'ads_transport.dart';

/// Talks to `/api/public/ads/*`.
class AdvertisingService implements AdvertisingGateway {
  AdvertisingService({required this.config, AdsTransport? transport})
    : _transport = transport ?? AdsTransport(config: config);

  final AdsConfig config;
  final AdsTransport _transport;

  static const int _maxExternalUserId = 150;
  static const int _maxAppName = 150;
  static const int _maxReferrer = 2048;

  @override
  bool get isConfigured => config.isConfigured;

  @override
  Uri? resolvePublicUrl(String? value) => config.resolvePublicUrl(value);

  @override
  Future<List<AdBannerModel>> fetchBanners() async {
    if (!isConfigured) throw const AdsFailure(AdsFailureKind.notConfigured);

    final origin = config.origin!;
    final response = await _transport.getJson(
      origin.replace(
        path: '/api/public/ads/banners',
        // Built through queryParameters so values are encoded properly, and
        // sectionCode is omitted entirely when unset rather than sent empty.
        queryParameters: <String, String>{
          'platform': config.platform,
          if (config.sectionCode.trim().isNotEmpty)
            'sectionCode': config.sectionCode.trim(),
        },
      ),
    );

    if (!response.isSuccess) {
      throw AdsTransport.failureFor(response.statusCode);
    }

    final payload = response.json;
    // null or [] is a valid "no active ads" answer, not an error.
    if (payload == null) return const <AdBannerModel>[];
    if (payload is! List) {
      throw const AdsFailure(AdsFailureKind.invalidResponse);
    }

    return payload
        .map(AdBannerModel.tryParse)
        .whereType<AdBannerModel>()
        .toList(growable: false);
  }

  @override
  Future<AdClickReceipt> registerClick({
    required String bannerId,
    required String externalUserId,
  }) async {
    if (!isConfigured) throw const AdsFailure(AdsFailureKind.notConfigured);

    final origin = config.origin!;
    final referrer =
        'https://parsikhesab.com/apps/${config.appName}/ads/$bannerId';

    // This endpoint is rate limited and a click must never be double counted,
    // so there is deliberately no retry anywhere in this method.
    final response = await _transport.postJson(
      origin.replace(path: '/api/public/ads/click'),
      <String, Object?>{
        'bannerId': bannerId,
        'externalUserId': _cap(externalUserId, _maxExternalUserId),
        'appName': _cap(config.appName, _maxAppName),
        'platform': config.platform,
        'referrerUrl': _cap(referrer, _maxReferrer),
      },
    );

    if (!response.isSuccess) {
      throw AdsTransport.failureFor(response.statusCode);
    }
    final receipt = AdClickReceipt.tryParse(response.json);
    if (receipt == null) {
      throw const AdsFailure(AdsFailureKind.invalidResponse);
    }
    return receipt;
  }

  static String _cap(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);

  @override
  void close() => _transport.close();
}

/// Talks to `/api/public/app-submissions/*`.
class AppSupportService implements AppSupportGateway {
  AppSupportService({required this.config, AdsTransport? transport})
    : _transport = transport ?? AdsTransport(config: config);

  final AdsConfig config;
  final AdsTransport _transport;

  @override
  bool get isConfigured => config.isConfigured;

  @override
  Future<SubmissionReceipt> submitErrorReport({
    required String description,
  }) {
    return _submit('/api/public/app-submissions/error-reports', <String, Object?>{
      'description': description.trim(),
    });
  }

  @override
  Future<SubmissionReceipt> submitAdvertisingRequest({
    required String fullName,
    required String phoneNumber,
    required String province,
    required String city,
    required String details,
  }) {
    return _submit(
      '/api/public/app-submissions/advertising-requests',
      <String, Object?>{
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'province': province.trim(),
        'city': city.trim(),
        'details': details.trim(),
      },
    );
  }

  Future<SubmissionReceipt> _submit(
    String path,
    Map<String, Object?> body,
  ) async {
    if (!isConfigured) throw const AdsFailure(AdsFailureKind.notConfigured);

    final response = await _transport.postJson(
      config.origin!.replace(path: path),
      body,
    );

    if (!response.isSuccess) {
      throw AdsTransport.failureFor(response.statusCode);
    }
    final receipt = SubmissionReceipt.tryParse(response.json);
    if (receipt == null) {
      throw const AdsFailure(AdsFailureKind.invalidResponse);
    }
    return receipt;
  }

  @override
  void close() => _transport.close();
}
