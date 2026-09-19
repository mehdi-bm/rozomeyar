import '../../core/utils/ids.dart';
import '../models/enums.dart';
import '../models/resume.dart';
import 'translation_service.dart';

/// Produces a translated copy of a resume.
///
/// Field selection is explicit rather than a blind walk over the JSON: emails,
/// phone numbers, URLs, photo paths and ids must survive untouched, and
/// machine-translating them would corrupt the document.
class ResumeTranslator {
  const ResumeTranslator(this._service);

  final TranslationService _service;

  /// Translates every text field of [source] into [target].
  ///
  /// The result is a brand-new resume — the original is never modified, so a
  /// bad translation can simply be deleted.
  Future<Resume> translate(
    Resume source, {
    required ResumeLanguage target,
    required String Function(String original) titleBuilder,
    void Function(int done, int total)? onProgress,
  }) async {
    if (target == source.language) return source;

    // One pass to collect, one to apply — both go through _mapText, so the two
    // can never disagree about which fields are translatable.
    final unique = <String>{};
    _mapText(source, (value) {
      unique.add(value);
      return value;
    });

    final translations = <String, String>{};
    var done = 0;
    onProgress?.call(0, unique.length);
    for (final text in unique) {
      translations[text] = await _service.translate(
        text,
        from: source.language,
        to: target,
      );
      done++;
      onProgress?.call(done, unique.length);
    }

    final translated = _mapText(
      source,
      (value) => translations[value] ?? value,
    );

    final now = DateTime.now();
    // A new id is essential: `copyWith` keeps the original's, which would make
    // saving the translation overwrite the resume it was translated from.
    return Resume(
      id: newId(),
      title: titleBuilder(source.title),
      language: target,
      isSample: false,
      personalInfo: translated.personalInfo,
      professionalSummary: translated.professionalSummary,
      experiences: translated.experiences,
      educations: translated.educations,
      skills: translated.skills,
      languages: translated.languages,
      projects: translated.projects,
      certifications: translated.certifications,
      links: translated.links,
      templateSettings: source.templateSettings,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Applies [f] to every translatable string, skipping blanks.
  ///
  /// Used both to enumerate the work and to apply the result.
  static Resume _mapText(Resume resume, String Function(String) f) {
    String? opt(String? value) {
      if (value == null || value.trim().isEmpty) return value;
      return f(value.trim());
    }

    String req(String value) => value.trim().isEmpty ? value : f(value.trim());

    /// Achievements are one item per line; translating the block as a whole
    /// loses the line breaks, so each line goes through separately.
    String? lines(String? value) {
      if (value == null || value.trim().isEmpty) return value;
      return value
          .split('\n')
          .map((line) => line.trim().isEmpty ? line : f(line.trim()))
          .join('\n');
    }

    final info = resume.personalInfo;

    return resume.copyWith(
      personalInfo: info.copyWith(
        firstName: req(info.firstName),
        lastName: req(info.lastName),
        jobTitle: req(info.jobTitle),
        city: opt(info.city),
        country: opt(info.country),
        address: opt(info.address),
      ),
      professionalSummary: req(resume.professionalSummary),
      experiences: resume.experiences
          .map(
            (e) => e.copyWith(
              jobTitle: req(e.jobTitle),
              company: req(e.company),
              city: opt(e.city),
              description: opt(e.description),
              achievements: lines(e.achievements),
            ),
          )
          .toList(),
      educations: resume.educations
          .map(
            (e) => e.copyWith(
              degree: req(e.degree),
              fieldOfStudy: req(e.fieldOfStudy),
              institution: req(e.institution),
              city: opt(e.city),
              description: opt(e.description),
            ),
          )
          .toList(),
      skills: resume.skills.map((e) => e.copyWith(name: req(e.name))).toList(),
      languages: resume.languages
          .map((e) => e.copyWith(name: req(e.name)))
          .toList(),
      projects: resume.projects
          .map(
            (e) => e.copyWith(
              name: req(e.name),
              role: opt(e.role),
              description: opt(e.description),
              technologies: opt(e.technologies),
            ),
          )
          .toList(),
      certifications: resume.certifications
          .map(
            (e) => e.copyWith(
              name: req(e.name),
              organization: opt(e.organization),
              description: opt(e.description),
            ),
          )
          .toList(),
      links: resume.links.map((e) => e.copyWith(title: req(e.title))).toList(),
    );
  }
}
