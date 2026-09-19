import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/data/local/resume_migrations.dart';
import 'package:resumeyar/domain/models/certification.dart';
import 'package:resumeyar/domain/models/education.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/experience.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/project.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/domain/models/resume_language_item.dart';
import 'package:resumeyar/domain/models/resume_link.dart';
import 'package:resumeyar/domain/models/skill.dart';
import 'package:resumeyar/domain/models/template_settings.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';

void main() {
  /// Round-trips through real JSON text, not just the map, so anything that
  /// `jsonEncode` cannot represent is caught.
  Resume roundTrip(Resume resume) => Resume.fromJson(
    jsonDecode(jsonEncode(resume.toJson())) as Map<String, dynamic>,
  );

  group('Resume JSON', () {
    test('round-trips the fully populated sample resume', () {
      for (final language in ResumeLanguage.values) {
        final original = SampleResume.build(language: language);
        expect(roundTrip(original), original);
      }
    });

    test('round-trips every optional field when set', () {
      final now = DateTime.utc(2026, 3, 14, 9, 30);
      final original = Resume(
        id: 'resume-1',
        title: 'کامل',
        language: ResumeLanguage.persian,
        isSample: true,
        createdAt: now,
        updatedAt: now,
        professionalSummary: 'خلاصه',
        personalInfo: PersonalInfo(
          firstName: 'مهدی',
          lastName: 'محمدی',
          jobTitle: 'برنامه‌نویس',
          photoPath: r'C:\photos\a.jpg',
          mobile: '۰۹۱۲',
          email: 'a@b.com',
          city: 'تهران',
          country: 'ایران',
          dateOfBirth: DateTime.utc(1990, 5, 6),
          address: 'خیابان نمونه',
          maritalStatus: MaritalStatus.married,
          visibility: const OptionalFieldVisibility(
            showDateOfBirth: true,
            showAddress: true,
            showMaritalStatus: true,
          ),
        ),
        experiences: <Experience>[
          Experience(
            id: 'e1',
            jobTitle: 'توسعه‌دهنده',
            company: 'شرکت',
            city: 'تهران',
            startDate: DateTime.utc(2020, 1),
            endDate: DateTime.utc(2022, 1),
            isCurrent: true,
            description: 'توضیح',
            achievements: 'یک\nدو',
          ),
        ],
        educations: <Education>[
          Education(
            id: 'ed1',
            degree: 'کارشناسی',
            fieldOfStudy: 'کامپیوتر',
            institution: 'دانشگاه',
            city: 'تهران',
            startDate: DateTime.utc(2011, 9),
            endDate: DateTime.utc(2015, 6),
            isCurrent: false,
            description: 'توضیح',
          ),
        ],
        skills: <Skill>[
          const Skill(id: 's1', name: 'Flutter', level: SkillLevel.expert),
          const Skill(id: 's2', name: 'SQL'),
        ],
        languages: <ResumeLanguageItem>[
          const ResumeLanguageItem(
            id: 'l1',
            name: 'انگلیسی',
            level: LanguageLevel.fluent,
          ),
        ],
        projects: <Project>[
          Project(
            id: 'p1',
            name: 'پروژه',
            role: 'توسعه‌دهنده',
            description: 'توضیح',
            technologies: 'Flutter',
            url: 'https://example.com',
            startDate: DateTime.utc(2021, 2),
            endDate: DateTime.utc(2021, 8),
          ),
        ],
        certifications: <Certification>[
          Certification(
            id: 'c1',
            name: 'دوره',
            organization: 'آکادمی',
            issueDate: DateTime.utc(2022, 5),
            credentialUrl: 'https://example.com/cert',
            description: 'توضیح',
          ),
        ],
        links: <ResumeLink>[
          const ResumeLink(
            id: 'k1',
            type: LinkType.github,
            title: 'گیت‌هاب',
            url: 'https://github.com/x',
          ),
        ],
        templateSettings: const TemplateSettings(
          templateId: TemplateId.minimal,
          accentColorValue: 0xFF0F766E,
          showProfilePhoto: false,
          showSkillLevels: false,
          fontScale: FontScale.large,
        ),
      );

      expect(roundTrip(original), original);
    });

    test('round-trips a resume with every optional field left null', () {
      final now = DateTime.utc(2026, 1, 1);
      final original = Resume(
        id: 'resume-2',
        title: '',
        createdAt: now,
        updatedAt: now,
        personalInfo: const PersonalInfo(),
      );

      final restored = roundTrip(original);
      expect(restored, original);
      expect(restored.personalInfo.photoPath, isNull);
      expect(restored.personalInfo.dateOfBirth, isNull);
      expect(restored.personalInfo.maritalStatus, isNull);
    });

    test('tolerates unknown enum names instead of throwing', () {
      final json = <String, dynamic>{
        'id': 'x',
        'title': 'y',
        'language': 'klingon',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'templateSettings': <String, dynamic>{
          'templateId': 'holographic',
          'fontScale': 'gigantic',
        },
        'skills': <dynamic>[
          <String, dynamic>{'id': 's', 'name': 'X', 'level': 'wizard'},
        ],
      };

      final resume = Resume.fromJson(json);
      expect(resume.language, ResumeLanguage.persian);
      expect(resume.templateSettings.templateId, TemplateId.classic);
      expect(resume.templateSettings.fontScale, FontScale.normal);
      expect(resume.skills.single.level, isNull);
    });

    test('tolerates wrong-typed and missing fields', () {
      final resume = Resume.fromJson(<String, dynamic>{
        'id': 'x',
        'title': 42,
        'experiences': 'not-a-list',
        'personalInfo': 'not-a-map',
      });

      expect(resume.title, '');
      expect(resume.experiences, isEmpty);
      expect(resume.personalInfo, const PersonalInfo());
    });
  });

  group('schema migration', () {
    test('stamps the current version onto an unversioned document', () {
      final migrated = migrateResumeJson(<String, dynamic>{'id': 'x'});
      expect(migrated['schemaVersion'], Resume.currentSchemaVersion);
    });

    test('leaves a current-version document untouched', () {
      final json = <String, dynamic>{
        'id': 'x',
        'schemaVersion': Resume.currentSchemaVersion,
      };
      expect(migrateResumeJson(json), json);
    });
  });

  group('visible sections', () {
    test('drop entries that carry no content', () {
      final now = DateTime.now();
      final resume = Resume(
        id: 'x',
        title: 't',
        createdAt: now,
        updatedAt: now,
        experiences: <Experience>[
          const Experience(id: '1'),
          const Experience(id: '2', jobTitle: 'توسعه‌دهنده'),
        ],
        skills: <Skill>[
          const Skill(id: '1'),
          const Skill(id: '2', name: 'Flutter'),
        ],
        links: <ResumeLink>[
          const ResumeLink(id: '1', title: 'خالی'),
          const ResumeLink(id: '2', title: 'گیت‌هاب', url: 'https://g.com'),
        ],
      );

      expect(resume.visibleExperiences.single.id, '2');
      expect(resume.visibleSkills.single.id, '2');
      expect(resume.visibleLinks.single.id, '2');
    });
  });

  group('achievementLines', () {
    test('splits on newlines and drops blanks', () {
      const item = Experience(
        id: '1',
        achievements: 'اول\n\n  دوم  \n\nسوم\n',
      );
      expect(item.achievementLines, <String>['اول', 'دوم', 'سوم']);
    });

    test('is empty when no achievements were entered', () {
      expect(const Experience(id: '1').achievementLines, isEmpty);
    });
  });
}
