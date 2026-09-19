import 'package:equatable/equatable.dart';

import 'json_utils.dart';
import 'section_item.dart';

class Experience extends Equatable implements SectionItem {
  const Experience({
    required this.id,
    this.jobTitle = '',
    this.company = '',
    this.city,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.achievements,
  });

  @override
  final String id;

  final String jobTitle;
  final String company;
  final String? city;
  final DateTime? startDate;
  final DateTime? endDate;

  /// When true the end date is rendered as «تاکنون» / "Present".
  final bool isCurrent;

  final String? description;

  /// Free text, one achievement per line. Templates render it as bullets.
  final String? achievements;

  List<String> get achievementLines => (achievements ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  bool get isEmpty =>
      jobTitle.trim().isEmpty &&
      company.trim().isEmpty &&
      (description ?? '').trim().isEmpty;

  Experience copyWith({
    String? jobTitle,
    String? company,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
    String? achievements,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return Experience(
      id: id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      city: city ?? this.city,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  Map<String, dynamic> toJson() => compact(<String, dynamic>{
    'id': id,
    'jobTitle': jobTitle,
    'company': company,
    'city': city,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
    'description': description,
    'achievements': achievements,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    id: readRequiredString(json, 'id'),
    jobTitle: readRequiredString(json, 'jobTitle'),
    company: readRequiredString(json, 'company'),
    city: readString(json, 'city'),
    startDate: readDate(json, 'startDate'),
    endDate: readDate(json, 'endDate'),
    isCurrent: readBool(json, 'isCurrent'),
    description: readString(json, 'description'),
    achievements: readString(json, 'achievements'),
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    jobTitle,
    company,
    city,
    startDate,
    endDate,
    isCurrent,
    description,
    achievements,
  ];
}
