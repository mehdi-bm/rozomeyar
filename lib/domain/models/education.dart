import 'package:equatable/equatable.dart';

import 'json_utils.dart';
import 'section_item.dart';

class Education extends Equatable implements SectionItem {
  const Education({
    required this.id,
    this.degree = '',
    this.fieldOfStudy = '',
    this.institution = '',
    this.city,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  @override
  final String id;

  final String degree;
  final String fieldOfStudy;
  final String institution;
  final String? city;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;

  /// "کارشناسی مهندسی نرم‌افزار" — degree and field read as one phrase.
  String get headline => <String>[
    degree.trim(),
    fieldOfStudy.trim(),
  ].where((part) => part.isNotEmpty).join(' ');

  bool get isEmpty =>
      degree.trim().isEmpty &&
      fieldOfStudy.trim().isEmpty &&
      institution.trim().isEmpty;

  Education copyWith({
    String? degree,
    String? fieldOfStudy,
    String? institution,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return Education(
      id: id,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      institution: institution ?? this.institution,
      city: city ?? this.city,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, dynamic> toJson() => compact(<String, dynamic>{
    'id': id,
    'degree': degree,
    'fieldOfStudy': fieldOfStudy,
    'institution': institution,
    'city': city,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
    'description': description,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    id: readRequiredString(json, 'id'),
    degree: readRequiredString(json, 'degree'),
    fieldOfStudy: readRequiredString(json, 'fieldOfStudy'),
    institution: readRequiredString(json, 'institution'),
    city: readString(json, 'city'),
    startDate: readDate(json, 'startDate'),
    endDate: readDate(json, 'endDate'),
    isCurrent: readBool(json, 'isCurrent'),
    description: readString(json, 'description'),
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    degree,
    fieldOfStudy,
    institution,
    city,
    startDate,
    endDate,
    isCurrent,
    description,
  ];
}
