import 'package:equatable/equatable.dart';

/// A banner returned by `GET /api/public/ads/banners`.
///
/// Parsing is tolerant of missing optional strings but an item without a
/// usable [bannerId] is dropped — a click could not be attributed to it.
class AdBannerModel extends Equatable {
  const AdBannerModel({
    required this.bannerId,
    this.bannerTitle = '',
    this.imageUrl = '',
    this.destinationUrl = '',
    this.campaignTitle = '',
    this.sectionName = '',
    this.sectionCode = '',
  });

  final String bannerId;
  final String bannerTitle;
  final String imageUrl;
  final String destinationUrl;
  final String campaignTitle;
  final String sectionName;
  final String sectionCode;

  static String _text(Object? value) =>
      value is String ? value.trim() : '';

  /// Returns null when the payload has no usable banner id.
  static AdBannerModel? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = _text(json['bannerId']);
    if (id.isEmpty) return null;
    return AdBannerModel(
      bannerId: id,
      bannerTitle: _text(json['bannerTitle']),
      imageUrl: _text(json['imageUrl']),
      destinationUrl: _text(json['destinationUrl']),
      campaignTitle: _text(json['campaignTitle']),
      sectionName: _text(json['sectionName']),
      sectionCode: _text(json['sectionCode']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    bannerId,
    bannerTitle,
    imageUrl,
    destinationUrl,
    campaignTitle,
    sectionName,
    sectionCode,
  ];
}

/// The 201 response of `POST /api/public/ads/click`.
class AdClickReceipt extends Equatable {
  const AdClickReceipt({required this.clickId, required this.destinationUrl});

  final String clickId;
  final String destinationUrl;

  static AdClickReceipt? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = json['clickId'];
    if (id is! String || id.trim().isEmpty) return null;
    final destination = json['destinationUrl'];
    return AdClickReceipt(
      clickId: id.trim(),
      destinationUrl: destination is String ? destination.trim() : '',
    );
  }

  @override
  List<Object?> get props => <Object?>[clickId, destinationUrl];
}

/// The 201 response of both app-submission endpoints.
class SubmissionReceipt extends Equatable {
  const SubmissionReceipt({
    required this.id,
    required this.type,
    required this.status,
  });

  final String id;
  final String type;
  final String status;

  /// An empty body or a missing id is *not* a success.
  static SubmissionReceipt? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) return null;
    return SubmissionReceipt(
      id: id.trim(),
      type: json['type'] is String ? (json['type'] as String).trim() : '',
      status: json['status'] is String ? (json['status'] as String).trim() : '',
    );
  }

  @override
  List<Object?> get props => <Object?>[id, type, status];
}
