import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'json_utils.dart';
import 'section_item.dart';

class Skill extends Equatable implements SectionItem {
  const Skill({required this.id, this.name = '', this.level});

  @override
  final String id;

  final String name;

  /// Optional — the user may keep skills as a plain list.
  final SkillLevel? level;

  bool get isEmpty => name.trim().isEmpty;

  Skill copyWith({String? name, SkillLevel? level, bool clearLevel = false}) {
    return Skill(
      id: id,
      name: name ?? this.name,
      level: clearLevel ? null : (level ?? this.level),
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      compact(<String, dynamic>{'id': id, 'name': name, 'level': level?.name});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: readRequiredString(json, 'id'),
    name: readRequiredString(json, 'name'),
    level: SkillLevel.fromName(readString(json, 'level')),
  );

  @override
  List<Object?> get props => <Object?>[id, name, level];
}
