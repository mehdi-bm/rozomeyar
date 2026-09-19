import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'json_utils.dart';
import 'section_item.dart';

/// A language the candidate speaks — not to be confused with [ResumeLanguage],
/// which is the language the resume document itself is written in.
class ResumeLanguageItem extends Equatable implements SectionItem {
  const ResumeLanguageItem({
    required this.id,
    this.name = '',
    this.level = LanguageLevel.intermediate,
  });

  @override
  final String id;

  final String name;
  final LanguageLevel level;

  bool get isEmpty => name.trim().isEmpty;

  ResumeLanguageItem copyWith({String? name, LanguageLevel? level}) {
    return ResumeLanguageItem(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'name': name, 'level': level.name};

  factory ResumeLanguageItem.fromJson(Map<String, dynamic> json) =>
      ResumeLanguageItem(
        id: readRequiredString(json, 'id'),
        name: readRequiredString(json, 'name'),
        level: LanguageLevel.fromName(readString(json, 'level')),
      );

  @override
  List<Object?> get props => <Object?>[id, name, level];
}
