import 'package:equatable/equatable.dart';

import 'json_utils.dart';
import 'section_item.dart';

class Project extends Equatable implements SectionItem {
  const Project({
    required this.id,
    this.name = '',
    this.role,
    this.description,
    this.technologies,
    this.url,
    this.startDate,
    this.endDate,
  });

  @override
  final String id;

  final String name;
  final String? role;
  final String? description;

  /// Comma-separated free text, e.g. "Flutter، Firebase، REST API".
  final String? technologies;

  final String? url;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isEmpty =>
      name.trim().isEmpty && (description ?? '').trim().isEmpty;

  Project copyWith({
    String? name,
    String? role,
    String? description,
    String? technologies,
    String? url,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      url: url ?? this.url,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  @override
  Map<String, dynamic> toJson() => compact(<String, dynamic>{
    'id': id,
    'name': name,
    'role': role,
    'description': description,
    'technologies': technologies,
    'url': url,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: readRequiredString(json, 'id'),
    name: readRequiredString(json, 'name'),
    role: readString(json, 'role'),
    description: readString(json, 'description'),
    technologies: readString(json, 'technologies'),
    url: readString(json, 'url'),
    startDate: readDate(json, 'startDate'),
    endDate: readDate(json, 'endDate'),
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    role,
    description,
    technologies,
    url,
    startDate,
    endDate,
  ];
}
