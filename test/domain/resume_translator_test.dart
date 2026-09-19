import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/domain/models/certification.dart';
import 'package:resumeyar/domain/models/education.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/experience.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/project.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/domain/models/resume_link.dart';
import 'package:resumeyar/domain/models/skill.dart';
import 'package:resumeyar/domain/services/resume_translator.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';

import '../support/fake_translation_service.dart';

void main() {
  late FakeTranslationService service;
  late ResumeTranslator translator;

  setUp(() {
    service = FakeTranslationService();
    translator = ResumeTranslator(service);
  });

  Future<Resume> translate(
    Resume source, {
    ResumeLanguage target = ResumeLanguage.english,
  }) {
    return translator.translate(
      source,
      target: target,
      titleBuilder: (original) => '$original (translated)',
    );
  }

  Resume buildResume() {
    final now = DateTime(2026, 1, 1);
    return Resume(
      id: 'source-id',
      title: 'رزومه من',
      createdAt: now,
      updatedAt: now,
      professionalSummary: 'خلاصه حرفه‌ای',
      personalInfo: const PersonalInfo(
        firstName: 'مهدی',
        lastName: 'محمدی',
        jobTitle: 'برنامه‌نویس',
        email: 'mehdi@example.com',
        mobile: '۰۹۱۲۳۴۵۶۷۸۹',
        photoPath: r'C:\photos\a.jpg',
        city: 'تهران',
      ),
      experiences: <Experience>[
        const Experience(
          id: 'e1',
          jobTitle: 'توسعه‌دهنده',
          company: 'شرکت نمونه',
          achievements: 'دستاورد اول\nدستاورد دوم',
        ),
      ],
      educations: <Education>[
        const Education(
          id: 'ed1',
          degree: 'کارشناسی',
          fieldOfStudy: 'کامپیوتر',
          institution: 'دانشگاه تهران',
        ),
      ],
      skills: <Skill>[const Skill(id: 's1', name: 'فلاتر')],
      projects: <Project>[
        const Project(
          id: 'p1',
          name: 'پروژه',
          url: 'https://example.com/project',
        ),
      ],
      certifications: <Certification>[
        const Certification(
          id: 'c1',
          name: 'دوره',
          credentialUrl: 'https://example.com/cert',
        ),
      ],
      links: <ResumeLink>[
        const ResumeLink(
          id: 'k1',
          title: 'گیت‌هاب',
          url: 'https://github.com/example',
        ),
      ],
    );
  }

  group('identity and safety', () {
    test('produces a new id so the original is never overwritten', () async {
      final source = buildResume();
      final result = await translate(source);

      expect(result.id, isNot(source.id));
      expect(result.id, isNotEmpty);
    });

    test('leaves the source resume untouched', () async {
      final source = buildResume();
      await translate(source);

      expect(source.personalInfo.firstName, 'مهدی');
      expect(source.title, 'رزومه من');
      expect(source.language, ResumeLanguage.persian);
    });

    test('switches the language, which drives direction and calendar',
        () async {
      final result = await translate(buildResume());
      expect(result.language, ResumeLanguage.english);
      expect(result.language.isRtl, isFalse);
    });

    test('a translated copy is never marked as the sample', () async {
      final sample = SampleResume.build(language: ResumeLanguage.persian);
      expect(sample.isSample, isTrue);

      final result = await translate(sample);
      expect(result.isSample, isFalse);
    });

    test('keeps the template settings', () async {
      final source = buildResume();
      final result = await translate(source);
      expect(result.templateSettings, source.templateSettings);
    });

    test('returns the source unchanged when the target matches', () async {
      final source = buildResume();
      final result = await translate(source, target: ResumeLanguage.persian);

      expect(identical(result, source), isTrue);
      expect(service.requested, isEmpty);
    });
  });

  group('what gets translated', () {
    test('translates the visible text fields', () async {
      final result = await translate(buildResume());

      expect(result.personalInfo.firstName, '[en]مهدی');
      expect(result.personalInfo.jobTitle, '[en]برنامه‌نویس');
      expect(result.professionalSummary, '[en]خلاصه حرفه‌ای');
      expect(result.experiences.single.company, '[en]شرکت نمونه');
      expect(result.educations.single.institution, '[en]دانشگاه تهران');
      expect(result.skills.single.name, '[en]فلاتر');
      expect(result.links.single.title, '[en]گیت‌هاب');
    });

    test('never touches contact details, URLs or file paths', () async {
      final result = await translate(buildResume());

      expect(result.personalInfo.email, 'mehdi@example.com');
      expect(result.personalInfo.mobile, '۰۹۱۲۳۴۵۶۷۸۹');
      expect(result.personalInfo.photoPath, r'C:\photos\a.jpg');
      expect(result.projects.single.url, 'https://example.com/project');
      expect(result.certifications.single.credentialUrl,
          'https://example.com/cert');
      expect(result.links.single.url, 'https://github.com/example');

      // And none of them were even sent to the service.
      expect(service.requested, isNot(contains('mehdi@example.com')));
      expect(
        service.requested,
        isNot(contains('https://github.com/example')),
      );
    });

    test('translates achievements line by line, preserving the breaks',
        () async {
      final result = await translate(buildResume());

      expect(
        result.experiences.single.achievements,
        '[en]دستاورد اول\n[en]دستاورد دوم',
      );
      expect(service.requested, contains('دستاورد اول'));
      expect(service.requested, contains('دستاورد دوم'));
    });

    test('leaves empty and null fields alone', () async {
      final now = DateTime(2026, 1, 1);
      final result = await translate(
        Resume(
          id: 'x',
          title: 't',
          createdAt: now,
          updatedAt: now,
          personalInfo: const PersonalInfo(firstName: 'علی', lastName: ''),
        ),
      );

      expect(result.personalInfo.lastName, '');
      expect(result.personalInfo.city, isNull);
      expect(result.professionalSummary, '');
    });

    test('sends each distinct string only once', () async {
      final now = DateTime(2026, 1, 1);
      final result = await translate(
        Resume(
          id: 'x',
          title: 't',
          createdAt: now,
          updatedAt: now,
          skills: <Skill>[
            const Skill(id: '1', name: 'تکرار'),
            const Skill(id: '2', name: 'تکرار'),
            const Skill(id: '3', name: 'یکتا'),
          ],
        ),
      );

      expect(service.requested.where((t) => t == 'تکرار'), hasLength(1));
      expect(result.skills.map((s) => s.name), <String>[
        '[en]تکرار',
        '[en]تکرار',
        '[en]یکتا',
      ]);
    });
  });

  group('progress reporting', () {
    test('ends at total and never exceeds it', () async {
      final updates = <(int, int)>[];
      await translator.translate(
        buildResume(),
        target: ResumeLanguage.arabic,
        titleBuilder: (original) => original,
        onProgress: (done, total) => updates.add((done, total)),
      );

      expect(updates, isNotEmpty);
      final total = updates.last.$2;
      expect(updates.last.$1, total);
      expect(updates.every((u) => u.$1 <= u.$2), isTrue);
      expect(updates.first.$1, 0);
    });
  });

  group('failures', () {
    test('surfaces a translation failure instead of a partial resume',
        () async {
      service.translateThrows = true;

      expect(
        () => translate(buildResume()),
        throwsA(isA<Object>()),
      );
    });
  });
}
