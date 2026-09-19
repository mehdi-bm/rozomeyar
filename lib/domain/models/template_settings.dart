import 'package:equatable/equatable.dart';

import '../../core/theme/app_colors.dart';
import 'enums.dart';
import 'json_utils.dart';

/// Per-resume appearance options. Deliberately small — V1 offers template,
/// accent colour, photo toggle, skill-level toggle and font size, nothing more.
class TemplateSettings extends Equatable {
  const TemplateSettings({
    this.templateId = TemplateId.classic,
    this.accentColorValue = _defaultAccent,
    this.showProfilePhoto = true,
    this.showSkillLevels = true,
    this.fontScale = FontScale.normal,
  });

  static const int _defaultAccent = 0xFF1F3864; // ResumeAccents.navy

  final TemplateId templateId;
  final int accentColorValue;
  final bool showProfilePhoto;
  final bool showSkillLevels;
  final FontScale fontScale;

  ResumeAccent get accent => ResumeAccents.fromValue(accentColorValue);

  TemplateSettings copyWith({
    TemplateId? templateId,
    int? accentColorValue,
    bool? showProfilePhoto,
    bool? showSkillLevels,
    FontScale? fontScale,
  }) {
    return TemplateSettings(
      templateId: templateId ?? this.templateId,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      showProfilePhoto: showProfilePhoto ?? this.showProfilePhoto,
      showSkillLevels: showSkillLevels ?? this.showSkillLevels,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'templateId': templateId.name,
    'accentColorValue': accentColorValue,
    'showProfilePhoto': showProfilePhoto,
    'showSkillLevels': showSkillLevels,
    'fontScale': fontScale.name,
  };

  factory TemplateSettings.fromJson(Map<String, dynamic> json) {
    return TemplateSettings(
      templateId: TemplateId.fromName(readString(json, 'templateId')),
      accentColorValue: readInt(
        json,
        'accentColorValue',
        fallback: _defaultAccent,
      ),
      showProfilePhoto: readBool(json, 'showProfilePhoto', fallback: true),
      showSkillLevels: readBool(json, 'showSkillLevels', fallback: true),
      fontScale: FontScale.fromName(readString(json, 'fontScale')),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    templateId,
    accentColorValue,
    showProfilePhoto,
    showSkillLevels,
    fontScale,
  ];
}
