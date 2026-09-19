import 'package:equatable/equatable.dart';

import 'certification.dart';
import 'education.dart';
import 'enums.dart';
import 'experience.dart';
import 'json_utils.dart';
import 'personal_info.dart';
import 'project.dart';
import 'resume_language_item.dart';
import 'resume_link.dart';
import 'skill.dart';
import 'template_settings.dart';

/// Root aggregate. One [Resume] is one JSON file on disk.
class Resume extends Equatable {
  const Resume({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = currentSchemaVersion,
    this.language = ResumeLanguage.persian,
    this.isSample = false,
    this.isFavorite = false,
    this.personalInfo = const PersonalInfo(),
    this.professionalSummary = '',
    this.experiences = const <Experience>[],
    this.educations = const <Education>[],
    this.skills = const <Skill>[],
    this.languages = const <ResumeLanguageItem>[],
    this.projects = const <Project>[],
    this.certifications = const <Certification>[],
    this.links = const <ResumeLink>[],
    this.templateSettings = const TemplateSettings(),
  });

  /// Bump when the on-disk shape changes, and add a step in
  /// `data/local/resume_migrations.dart`.
  static const int currentSchemaVersion = 1;

  final String id;
  final int schemaVersion;
  final String title;
  final ResumeLanguage language;

  /// Marks the seeded «نمونه رزومه» so it can be badged and duplicated.
  final bool isSample;

  /// Starred by the user, so the home screen can filter down to it.
  final bool isFavorite;

  final PersonalInfo personalInfo;
  final String professionalSummary;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<ResumeLanguageItem> languages;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<ResumeLink> links;
  final TemplateSettings templateSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Templates render only sections that survive these filters, so a section
  // whose items were all left blank produces no heading in the PDF.
  List<Experience> get visibleExperiences =>
      experiences.where((item) => !item.isEmpty).toList(growable: false);

  List<Education> get visibleEducations =>
      educations.where((item) => !item.isEmpty).toList(growable: false);

  List<Skill> get visibleSkills =>
      skills.where((item) => !item.isEmpty).toList(growable: false);

  List<ResumeLanguageItem> get visibleLanguages =>
      languages.where((item) => !item.isEmpty).toList(growable: false);

  List<Project> get visibleProjects =>
      projects.where((item) => !item.isEmpty).toList(growable: false);

  List<Certification> get visibleCertifications =>
      certifications.where((item) => !item.isEmpty).toList(growable: false);

  List<ResumeLink> get visibleLinks =>
      links.where((item) => !item.isEmpty).toList(growable: false);

  bool get hasSummary => professionalSummary.trim().isNotEmpty;

  /// Rough completeness signal for the home card progress hint.
  double get completeness {
    final checks = <bool>[
      personalInfo.firstName.trim().isNotEmpty,
      personalInfo.lastName.trim().isNotEmpty,
      personalInfo.jobTitle.trim().isNotEmpty,
      (personalInfo.email ?? '').trim().isNotEmpty ||
          (personalInfo.mobile ?? '').trim().isNotEmpty,
      hasSummary,
      visibleExperiences.isNotEmpty,
      visibleEducations.isNotEmpty,
      visibleSkills.isNotEmpty,
    ];
    final done = checks.where((value) => value).length;
    return done / checks.length;
  }

  Resume copyWith({
    String? title,
    ResumeLanguage? language,
    bool? isSample,
    bool? isFavorite,
    PersonalInfo? personalInfo,
    String? professionalSummary,
    List<Experience>? experiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<ResumeLanguageItem>? languages,
    List<Project>? projects,
    List<Certification>? certifications,
    List<ResumeLink>? links,
    TemplateSettings? templateSettings,
    DateTime? updatedAt,
  }) {
    return Resume(
      id: id,
      schemaVersion: schemaVersion,
      title: title ?? this.title,
      language: language ?? this.language,
      isSample: isSample ?? this.isSample,
      isFavorite: isFavorite ?? this.isFavorite,
      personalInfo: personalInfo ?? this.personalInfo,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      links: links ?? this.links,
      templateSettings: templateSettings ?? this.templateSettings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'schemaVersion': schemaVersion,
    'title': title,
    'language': language.name,
    'isSample': isSample,
    'isFavorite': isFavorite,
    'personalInfo': personalInfo.toJson(),
    'professionalSummary': professionalSummary,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'educations': educations.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'languages': languages.map((e) => e.toJson()).toList(),
    'projects': projects.map((e) => e.toJson()).toList(),
    'certifications': certifications.map((e) => e.toJson()).toList(),
    'links': links.map((e) => e.toJson()).toList(),
    'templateSettings': templateSettings.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Resume.fromJson(Map<String, dynamic> json) {
    final personalInfo = json['personalInfo'];
    final templateSettings = json['templateSettings'];
    return Resume(
      id: readRequiredString(json, 'id'),
      schemaVersion: readInt(
        json,
        'schemaVersion',
        fallback: currentSchemaVersion,
      ),
      title: readRequiredString(json, 'title'),
      language: ResumeLanguage.fromName(readString(json, 'language')),
      isSample: readBool(json, 'isSample'),
      isFavorite: readBool(json, 'isFavorite'),
      personalInfo: personalInfo is Map<String, dynamic>
          ? PersonalInfo.fromJson(personalInfo)
          : const PersonalInfo(),
      professionalSummary: readRequiredString(json, 'professionalSummary'),
      experiences: readList(json, 'experiences', Experience.fromJson),
      educations: readList(json, 'educations', Education.fromJson),
      skills: readList(json, 'skills', Skill.fromJson),
      languages: readList(json, 'languages', ResumeLanguageItem.fromJson),
      projects: readList(json, 'projects', Project.fromJson),
      certifications: readList(json, 'certifications', Certification.fromJson),
      links: readList(json, 'links', ResumeLink.fromJson),
      templateSettings: templateSettings is Map<String, dynamic>
          ? TemplateSettings.fromJson(templateSettings)
          : const TemplateSettings(),
      createdAt: readRequiredDate(json, 'createdAt'),
      updatedAt: readRequiredDate(json, 'updatedAt'),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    schemaVersion,
    title,
    language,
    isSample,
    isFavorite,
    personalInfo,
    professionalSummary,
    experiences,
    educations,
    skills,
    languages,
    projects,
    certifications,
    links,
    templateSettings,
    createdAt,
    updatedAt,
  ];
}
