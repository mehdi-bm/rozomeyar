import 'dart:typed_data';

import '../../core/utils/ids.dart';
import '../../domain/models/certification.dart';
import '../../domain/models/education.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/experience.dart';
import '../../domain/models/personal_info.dart';
import '../../domain/models/project.dart';
import '../../domain/models/resume.dart';
import '../../domain/models/resume_language_item.dart';
import '../../domain/models/resume_link.dart';
import '../../domain/models/skill.dart';
import '../../domain/models/template_settings.dart';
import 'xlsx.dart';

/// Maps a [Resume] to and from a spreadsheet workbook.
///
/// One sheet per section, with a header row naming each column, so the file is
/// readable and editable in Excel rather than being an opaque dump.
///
/// **Not included: the profile photo.** A cell caps out at 32,767 characters,
/// which a base64 image blows past, so the image file itself cannot ride along.
/// Import therefore leaves the photo empty — this is a content backup, not a
/// byte-for-byte one.
///
/// Dates are stored ISO-8601 in a hidden-ish `date` column rather than
/// localised, because a Jalali string cannot be parsed back unambiguously.
abstract final class ResumeWorkbook {
  static const String _meta = 'Meta';
  static const String _personal = 'PersonalInfo';
  static const String _experience = 'Experience';
  static const String _education = 'Education';
  static const String _skills = 'Skills';
  static const String _languages = 'Languages';
  static const String _projects = 'Projects';
  static const String _certifications = 'Certifications';
  static const String _links = 'Links';

  /// Bumped if the sheet layout changes, so a future import can adapt.
  static const int formatVersion = 1;

  static Uint8List encode(Resume resume) {
    final info = resume.personalInfo;

    String date(DateTime? value) => value?.toIso8601String() ?? '';
    String flag(bool value) => value ? 'true' : 'false';

    return Xlsx.encode(<String, List<List<String>>>{
      _meta: <List<String>>[
        <String>['key', 'value'],
        <String>['formatVersion', '$formatVersion'],
        <String>['schemaVersion', '${resume.schemaVersion}'],
        <String>['title', resume.title],
        <String>['language', resume.language.name],
        <String>['isFavorite', flag(resume.isFavorite)],
        <String>['templateId', resume.templateSettings.templateId.name],
        <String>[
          'accentColorValue',
          '${resume.templateSettings.accentColorValue}',
        ],
        <String>[
          'showProfilePhoto',
          flag(resume.templateSettings.showProfilePhoto),
        ],
        <String>[
          'showSkillLevels',
          flag(resume.templateSettings.showSkillLevels),
        ],
        <String>['fontScale', resume.templateSettings.fontScale.name],
        <String>['professionalSummary', resume.professionalSummary],
      ],
      _personal: <List<String>>[
        <String>['field', 'value'],
        <String>['firstName', info.firstName],
        <String>['lastName', info.lastName],
        <String>['jobTitle', info.jobTitle],
        <String>['mobile', info.mobile ?? ''],
        <String>['email', info.email ?? ''],
        <String>['city', info.city ?? ''],
        <String>['country', info.country ?? ''],
        <String>['dateOfBirth', date(info.dateOfBirth)],
        <String>['address', info.address ?? ''],
        <String>['maritalStatus', info.maritalStatus?.name ?? ''],
        <String>['showDateOfBirth', flag(info.visibility.showDateOfBirth)],
        <String>['showAddress', flag(info.visibility.showAddress)],
        <String>['showMaritalStatus', flag(info.visibility.showMaritalStatus)],
      ],
      _experience: <List<String>>[
        <String>[
          'jobTitle',
          'company',
          'city',
          'startDate',
          'endDate',
          'isCurrent',
          'description',
          'achievements',
        ],
        for (final e in resume.experiences)
          <String>[
            e.jobTitle,
            e.company,
            e.city ?? '',
            date(e.startDate),
            date(e.endDate),
            flag(e.isCurrent),
            e.description ?? '',
            e.achievements ?? '',
          ],
      ],
      _education: <List<String>>[
        <String>[
          'degree',
          'fieldOfStudy',
          'institution',
          'city',
          'startDate',
          'endDate',
          'isCurrent',
          'description',
        ],
        for (final e in resume.educations)
          <String>[
            e.degree,
            e.fieldOfStudy,
            e.institution,
            e.city ?? '',
            date(e.startDate),
            date(e.endDate),
            flag(e.isCurrent),
            e.description ?? '',
          ],
      ],
      _skills: <List<String>>[
        <String>['name', 'level'],
        for (final s in resume.skills)
          <String>[s.name, s.level?.name ?? ''],
      ],
      _languages: <List<String>>[
        <String>['name', 'level'],
        for (final l in resume.languages) <String>[l.name, l.level.name],
      ],
      _projects: <List<String>>[
        <String>[
          'name',
          'role',
          'description',
          'technologies',
          'url',
          'startDate',
          'endDate',
        ],
        for (final p in resume.projects)
          <String>[
            p.name,
            p.role ?? '',
            p.description ?? '',
            p.technologies ?? '',
            p.url ?? '',
            date(p.startDate),
            date(p.endDate),
          ],
      ],
      _certifications: <List<String>>[
        <String>[
          'name',
          'organization',
          'issueDate',
          'credentialUrl',
          'description',
        ],
        for (final c in resume.certifications)
          <String>[
            c.name,
            c.organization ?? '',
            date(c.issueDate),
            c.credentialUrl ?? '',
            c.description ?? '',
          ],
      ],
      _links: <List<String>>[
        <String>['type', 'title', 'url'],
        for (final l in resume.links) <String>[l.type.name, l.title, l.url],
      ],
    });
  }

  /// Rebuilds a resume from a workbook.
  ///
  /// Always produces a **new id** so importing can never overwrite an existing
  /// resume — a restore adds, it does not replace.
  ///
  /// Throws [FormatException] when the file is not a resume backup at all.
  static Resume decode(Uint8List bytes) {
    final sheets = Xlsx.decode(bytes);

    final meta = _keyValues(sheets[_meta]);
    if (meta.isEmpty || !meta.containsKey('language')) {
      throw const FormatException('not a ResumeYar backup');
    }
    final personal = _keyValues(sheets[_personal]);

    DateTime? date(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    bool flag(String? value) => value == 'true';

    final now = DateTime.now();
    return Resume(
      id: newId(),
      title: meta['title']?.trim().isNotEmpty == true
          ? meta['title']!
          : 'رزومه',
      language: ResumeLanguage.fromName(meta['language']),
      isFavorite: flag(meta['isFavorite']),
      professionalSummary: meta['professionalSummary'] ?? '',
      createdAt: now,
      updatedAt: now,
      personalInfo: PersonalInfo(
        firstName: personal['firstName'] ?? '',
        lastName: personal['lastName'] ?? '',
        jobTitle: personal['jobTitle'] ?? '',
        // The image itself is not in the workbook, so it cannot be restored.
        mobile: _orNull(personal['mobile']),
        email: _orNull(personal['email']),
        city: _orNull(personal['city']),
        country: _orNull(personal['country']),
        dateOfBirth: date(personal['dateOfBirth']),
        address: _orNull(personal['address']),
        maritalStatus: MaritalStatus.fromName(
          _orNull(personal['maritalStatus']),
        ),
        visibility: OptionalFieldVisibility(
          showDateOfBirth: flag(personal['showDateOfBirth']),
          showAddress: flag(personal['showAddress']),
          showMaritalStatus: flag(personal['showMaritalStatus']),
        ),
      ),
      experiences: _rows(sheets[_experience])
          .map(
            (r) => Experience(
              id: newId(),
              jobTitle: r['jobTitle'] ?? '',
              company: r['company'] ?? '',
              city: _orNull(r['city']),
              startDate: date(r['startDate']),
              endDate: date(r['endDate']),
              isCurrent: flag(r['isCurrent']),
              description: _orNull(r['description']),
              achievements: _orNull(r['achievements']),
            ),
          )
          .toList(),
      educations: _rows(sheets[_education])
          .map(
            (r) => Education(
              id: newId(),
              degree: r['degree'] ?? '',
              fieldOfStudy: r['fieldOfStudy'] ?? '',
              institution: r['institution'] ?? '',
              city: _orNull(r['city']),
              startDate: date(r['startDate']),
              endDate: date(r['endDate']),
              isCurrent: flag(r['isCurrent']),
              description: _orNull(r['description']),
            ),
          )
          .toList(),
      skills: _rows(sheets[_skills])
          .map(
            (r) => Skill(
              id: newId(),
              name: r['name'] ?? '',
              level: SkillLevel.fromName(_orNull(r['level'])),
            ),
          )
          .toList(),
      languages: _rows(sheets[_languages])
          .map(
            (r) => ResumeLanguageItem(
              id: newId(),
              name: r['name'] ?? '',
              level: LanguageLevel.fromName(r['level']),
            ),
          )
          .toList(),
      projects: _rows(sheets[_projects])
          .map(
            (r) => Project(
              id: newId(),
              name: r['name'] ?? '',
              role: _orNull(r['role']),
              description: _orNull(r['description']),
              technologies: _orNull(r['technologies']),
              url: _orNull(r['url']),
              startDate: date(r['startDate']),
              endDate: date(r['endDate']),
            ),
          )
          .toList(),
      certifications: _rows(sheets[_certifications])
          .map(
            (r) => Certification(
              id: newId(),
              name: r['name'] ?? '',
              organization: _orNull(r['organization']),
              issueDate: date(r['issueDate']),
              credentialUrl: _orNull(r['credentialUrl']),
              description: _orNull(r['description']),
            ),
          )
          .toList(),
      links: _rows(sheets[_links])
          .map(
            (r) => ResumeLink(
              id: newId(),
              type: LinkType.fromName(r['type']),
              title: r['title'] ?? '',
              url: r['url'] ?? '',
            ),
          )
          .toList(),
      templateSettings: TemplateSettings(
        templateId: TemplateId.fromName(meta['templateId']),
        accentColorValue:
            int.tryParse(meta['accentColorValue'] ?? '') ??
                const TemplateSettings().accentColorValue,
        showProfilePhoto: meta['showProfilePhoto'] != 'false',
        showSkillLevels: meta['showSkillLevels'] != 'false',
        fontScale: FontScale.fromName(meta['fontScale']),
      ),
    );
  }

  static String? _orNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value;

  /// Reads a two-column `key | value` sheet, skipping its header row.
  static Map<String, String> _keyValues(List<List<String>>? rows) {
    if (rows == null || rows.length < 2) return <String, String>{};
    final result = <String, String>{};
    for (final row in rows.skip(1)) {
      if (row.isEmpty || row[0].trim().isEmpty) continue;
      result[row[0].trim()] = row.length > 1 ? row[1] : '';
    }
    return result;
  }

  /// Reads a table sheet into one map per row, keyed by the header names.
  ///
  /// Rows where every cell is blank are dropped, so trailing empty rows left
  /// behind by Excel do not turn into empty resume entries.
  static List<Map<String, String>> _rows(List<List<String>>? rows) {
    if (rows == null || rows.length < 2) return <Map<String, String>>[];
    final headers = rows.first.map((h) => h.trim()).toList();
    final result = <Map<String, String>>[];

    for (final row in rows.skip(1)) {
      if (row.every((cell) => cell.trim().isEmpty)) continue;
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        if (headers[i].isEmpty) continue;
        map[headers[i]] = row[i];
      }
      result.add(map);
    }
    return result;
  }
}
