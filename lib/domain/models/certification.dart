import 'package:equatable/equatable.dart';

import 'json_utils.dart';
import 'section_item.dart';

class Certification extends Equatable implements SectionItem {
  const Certification({
    required this.id,
    this.name = '',
    this.organization,
    this.issueDate,
    this.credentialUrl,
    this.description,
  });

  @override
  final String id;

  final String name;
  final String? organization;
  final DateTime? issueDate;
  final String? credentialUrl;
  final String? description;

  bool get isEmpty => name.trim().isEmpty;

  Certification copyWith({
    String? name,
    String? organization,
    DateTime? issueDate,
    String? credentialUrl,
    String? description,
    bool clearIssueDate = false,
  }) {
    return Certification(
      id: id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      issueDate: clearIssueDate ? null : (issueDate ?? this.issueDate),
      credentialUrl: credentialUrl ?? this.credentialUrl,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, dynamic> toJson() => compact(<String, dynamic>{
    'id': id,
    'name': name,
    'organization': organization,
    'issueDate': issueDate?.toIso8601String(),
    'credentialUrl': credentialUrl,
    'description': description,
  });

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
    id: readRequiredString(json, 'id'),
    name: readRequiredString(json, 'name'),
    organization: readString(json, 'organization'),
    issueDate: readDate(json, 'issueDate'),
    credentialUrl: readString(json, 'credentialUrl'),
    description: readString(json, 'description'),
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    organization,
    issueDate,
    credentialUrl,
    description,
  ];
}
