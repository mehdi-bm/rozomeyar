import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'json_utils.dart';

/// Which optional personal fields the user wants printed on the resume.
///
/// Filling a field and showing it are separate decisions — a user may store
/// their address but keep it off the document.
class OptionalFieldVisibility extends Equatable {
  const OptionalFieldVisibility({
    this.showDateOfBirth = false,
    this.showAddress = false,
    this.showMaritalStatus = false,
  });

  final bool showDateOfBirth;
  final bool showAddress;
  final bool showMaritalStatus;

  OptionalFieldVisibility copyWith({
    bool? showDateOfBirth,
    bool? showAddress,
    bool? showMaritalStatus,
  }) {
    return OptionalFieldVisibility(
      showDateOfBirth: showDateOfBirth ?? this.showDateOfBirth,
      showAddress: showAddress ?? this.showAddress,
      showMaritalStatus: showMaritalStatus ?? this.showMaritalStatus,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'showDateOfBirth': showDateOfBirth,
    'showAddress': showAddress,
    'showMaritalStatus': showMaritalStatus,
  };

  factory OptionalFieldVisibility.fromJson(Map<String, dynamic> json) {
    return OptionalFieldVisibility(
      showDateOfBirth: readBool(json, 'showDateOfBirth'),
      showAddress: readBool(json, 'showAddress'),
      showMaritalStatus: readBool(json, 'showMaritalStatus'),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    showDateOfBirth,
    showAddress,
    showMaritalStatus,
  ];
}

class PersonalInfo extends Equatable {
  const PersonalInfo({
    this.firstName = '',
    this.lastName = '',
    this.jobTitle = '',
    this.photoPath,
    this.mobile,
    this.email,
    this.city,
    this.country,
    this.dateOfBirth,
    this.address,
    this.maritalStatus,
    this.visibility = const OptionalFieldVisibility(),
  });

  final String firstName;
  final String lastName;
  final String jobTitle;
  final String? photoPath;
  final String? mobile;
  final String? email;
  final String? city;
  final String? country;
  final DateTime? dateOfBirth;
  final String? address;
  final MaritalStatus? maritalStatus;
  final OptionalFieldVisibility visibility;

  String get fullName => <String>[
    firstName.trim(),
    lastName.trim(),
  ].where((part) => part.isNotEmpty).join(' ');

  /// "تهران، ایران" / "Tehran, Iran" — whichever parts exist.
  String? location(String separator) {
    final parts = <String>[
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (country != null && country!.trim().isNotEmpty) country!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(separator);
  }

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? photoPath,
    String? mobile,
    String? email,
    String? city,
    String? country,
    DateTime? dateOfBirth,
    String? address,
    MaritalStatus? maritalStatus,
    OptionalFieldVisibility? visibility,
    bool clearPhoto = false,
    bool clearDateOfBirth = false,
    bool clearMaritalStatus = false,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      jobTitle: jobTitle ?? this.jobTitle,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      country: country ?? this.country,
      dateOfBirth:
          clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      address: address ?? this.address,
      maritalStatus:
          clearMaritalStatus ? null : (maritalStatus ?? this.maritalStatus),
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toJson() => compact(<String, dynamic>{
    'firstName': firstName,
    'lastName': lastName,
    'jobTitle': jobTitle,
    'photoPath': photoPath,
    'mobile': mobile,
    'email': email,
    'city': city,
    'country': country,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'address': address,
    'maritalStatus': maritalStatus?.name,
    'visibility': visibility.toJson(),
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    final visibility = json['visibility'];
    return PersonalInfo(
      firstName: readRequiredString(json, 'firstName'),
      lastName: readRequiredString(json, 'lastName'),
      jobTitle: readRequiredString(json, 'jobTitle'),
      photoPath: readString(json, 'photoPath'),
      mobile: readString(json, 'mobile'),
      email: readString(json, 'email'),
      city: readString(json, 'city'),
      country: readString(json, 'country'),
      dateOfBirth: readDate(json, 'dateOfBirth'),
      address: readString(json, 'address'),
      maritalStatus: MaritalStatus.fromName(readString(json, 'maritalStatus')),
      visibility: visibility is Map<String, dynamic>
          ? OptionalFieldVisibility.fromJson(visibility)
          : const OptionalFieldVisibility(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    firstName,
    lastName,
    jobTitle,
    photoPath,
    mobile,
    email,
    city,
    country,
    dateOfBirth,
    address,
    maritalStatus,
    visibility,
  ];
}
