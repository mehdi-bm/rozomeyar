import 'dart:async';

import 'package:resumeyar/features/ads/config/ads_config.dart';
import 'package:resumeyar/features/ads/domain/ad_models.dart';
import 'package:resumeyar/features/ads/domain/advertising_gateway.dart';
import 'package:resumeyar/features/ads/domain/ads_failure.dart';

/// Config with obviously fake keys. Real keys must never appear in tests.
const AdsConfig testAdsConfig = AdsConfig(
  baseUrl: 'https://ads.example.test/',
  apiKey: 'test-api-key',
  externalAppApiKey: 'test-external-key',
  appName: 'resumeyar',
  platform: 'Android',
  sectionCode: 'test_section',
);

class FakeAdvertisingGateway implements AdvertisingGateway {
  FakeAdvertisingGateway({
    this.banners = const <AdBannerModel>[],
    this.fetchFailure,
    this.clickFailure,
    this.clickDestination = 'https://ads.example.test/landing',
    this.isConfigured = true,
  });

  List<AdBannerModel> banners;
  AdsFailureKind? fetchFailure;
  AdsFailureKind? clickFailure;
  String clickDestination;

  @override
  bool isConfigured;

  int fetchCount = 0;

  /// Every click registered, so a test can prove a double tap only sent one.
  final List<String> clickedBannerIds = <String>[];
  final List<String> clickedUserIds = <String>[];

  /// When set, `registerClick` waits on this before completing, so a test can
  /// keep a click genuinely in flight and tap again — which is the only way to
  /// exercise the double-tap guard. Without it the fake resolves on a
  /// microtask and each tap finishes before the next begins.
  Completer<void>? holdClicks;

  bool closed = false;

  @override
  Future<List<AdBannerModel>> fetchBanners() async {
    fetchCount++;
    final failure = fetchFailure;
    if (failure != null) throw AdsFailure(failure);
    return banners;
  }

  @override
  Future<AdClickReceipt> registerClick({
    required String bannerId,
    required String externalUserId,
  }) async {
    clickedBannerIds.add(bannerId);
    clickedUserIds.add(externalUserId);
    final hold = holdClicks;
    if (hold != null) await hold.future;
    final failure = clickFailure;
    if (failure != null) throw AdsFailure(failure);
    return AdClickReceipt(
      clickId: 'click-1',
      destinationUrl: clickDestination,
    );
  }

  @override
  Uri? resolvePublicUrl(String? value) => testAdsConfig.resolvePublicUrl(value);

  @override
  void close() => closed = true;
}

class FakeAppSupportGateway implements AppSupportGateway {
  FakeAppSupportGateway({this.failure, this.isConfigured = true});

  AdsFailureKind? failure;

  @override
  bool isConfigured;

  final List<String> errorReports = <String>[];
  final List<Map<String, String>> advertisingRequests =
      <Map<String, String>>[];

  bool closed = false;

  @override
  Future<SubmissionReceipt> submitErrorReport({
    required String description,
  }) async {
    final kind = failure;
    if (kind != null) throw AdsFailure(kind);
    errorReports.add(description);
    return const SubmissionReceipt(
      id: 'submission-1',
      type: 'ErrorReport',
      status: 'New',
    );
  }

  @override
  Future<SubmissionReceipt> submitAdvertisingRequest({
    required String fullName,
    required String phoneNumber,
    required String province,
    required String city,
    required String details,
  }) async {
    final kind = failure;
    if (kind != null) throw AdsFailure(kind);
    advertisingRequests.add(<String, String>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'province': province,
      'city': city,
      'details': details,
    });
    return const SubmissionReceipt(
      id: 'submission-2',
      type: 'AdvertisingRequest',
      status: 'New',
    );
  }

  @override
  void close() => closed = true;
}
