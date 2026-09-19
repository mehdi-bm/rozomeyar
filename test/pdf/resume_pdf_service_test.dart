import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/ids.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/experience.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/domain/models/skill.dart';
import 'package:resumeyar/domain/models/template_settings.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';
import 'package:resumeyar/pdf/pdf_fonts.dart';
import 'package:resumeyar/pdf/resume_pdf_service.dart';

import '../support/test_fonts.dart';

void main() {
  const service = ResumePdfService();
  late PdfFonts fonts;

  setUpAll(() {
    fonts = loadTestFonts();
  });

  group('document generation', () {
    for (final language in ResumeLanguage.values) {
      for (final template in TemplateId.values) {
        test('renders ${template.name} in ${language.name}', () async {
          final resume = SampleResume.build(language: language).copyWith(
            templateSettings: TemplateSettings(templateId: template),
          );

          final bytes = await service.buildWithFonts(resume, fonts);

          expect(bytes.length, greaterThan(2000));
          // Every PDF starts with the %PDF- header and ends with %%EOF.
          expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        });
      }
    }

    test('a long resume paginates instead of throwing', () async {
      final base = SampleResume.build(language: ResumeLanguage.persian);
      final manyExperiences = <Experience>[
        for (var i = 0; i < 25; i++)
          Experience(
            id: newId(),
            jobTitle: 'توسعه‌دهنده نرم‌افزار شماره ${i + 1}',
            company: 'شرکت نمونه شماره ${i + 1}',
            startDate: DateTime(2015 + (i % 8), 3),
            endDate: DateTime(2016 + (i % 8), 3),
            description:
                'شرح مفصل وظایف و مسئولیت‌ها در این نقش، شامل طراحی، توسعه، '
                'تست و پشتیبانی از سامانه‌های مختلف سازمانی و تیمی.',
            achievements: 'دستاورد اول\nدستاورد دوم\nدستاورد سوم',
          ),
      ];

      for (final template in TemplateId.values) {
        final resume = base.copyWith(
          experiences: manyExperiences,
          templateSettings: TemplateSettings(templateId: template),
        );
        final bytes = await service.buildWithFonts(resume, fonts);
        expect(
          bytes.length,
          greaterThan(2000),
          reason: '${template.name} failed to paginate a long resume',
        );
      }
    });

    test('an almost-empty resume still produces a document', () async {
      final now = DateTime.now();
      final resume = Resume(
        id: newId(),
        title: 'خالی',
        createdAt: now,
        updatedAt: now,
        personalInfo: const PersonalInfo(firstName: 'علی', lastName: 'رضایی'),
      );

      final bytes = await service.buildWithFonts(resume, fonts);
      expect(bytes.length, greaterThan(1000));
    });

    test('hides sections whose items are all blank', () async {
      final now = DateTime.now();
      final resume = Resume(
        id: newId(),
        title: 'خالی',
        createdAt: now,
        updatedAt: now,
        personalInfo: const PersonalInfo(firstName: 'علی', lastName: 'رضایی'),
        // Entries that exist but carry no content must not create a heading.
        experiences: <Experience>[Experience(id: newId())],
        skills: <Skill>[Skill(id: newId())],
      );

      expect(resume.visibleExperiences, isEmpty);
      expect(resume.visibleSkills, isEmpty);

      final bytes = await service.buildWithFonts(resume, fonts);
      expect(bytes.length, greaterThan(1000));
    });
  });

  group('fileName', () {
    Resume resumeWith({
      required ResumeLanguage language,
      required String first,
      required String last,
    }) {
      final now = DateTime.now();
      return Resume(
        id: newId(),
        title: 'x',
        language: language,
        createdAt: now,
        updatedAt: now,
        personalInfo: PersonalInfo(firstName: first, lastName: last),
      );
    }

    test('uses a Persian name for Persian resumes', () {
      final name = service.fileName(
        resumeWith(
          language: ResumeLanguage.persian,
          first: 'مهدی',
          last: 'محمدی',
        ),
      );
      expect(name, 'رزومه_مهدی.pdf');
    });

    test('uses an English name and year for English resumes', () {
      final name = service.fileName(
        resumeWith(
          language: ResumeLanguage.english,
          first: 'Mehdi',
          last: 'Mohammadi',
        ),
      );
      expect(name, 'Resume_Mehdi_${DateTime.now().year}.pdf');
    });

    test('falls back when no name is entered', () {
      expect(
        service.fileName(
          resumeWith(language: ResumeLanguage.persian, first: '', last: ''),
        ),
        'رزومه.pdf',
      );
      expect(
        service.fileName(
          resumeWith(language: ResumeLanguage.english, first: '', last: ''),
        ),
        'Resume_${DateTime.now().year}.pdf',
      );
    });

    test('uses the last name when only it is filled', () {
      expect(
        service.fileName(
          resumeWith(
            language: ResumeLanguage.persian,
            first: '',
            last: 'محمدی',
          ),
        ),
        'رزومه_محمدی.pdf',
      );
    });

    test('strips characters that are illegal in filenames', () {
      final name = service.fileName(
        resumeWith(
          language: ResumeLanguage.english,
          first: 'Me/hd:i*?',
          last: 'X',
        ),
      );
      expect(name, 'Resume_Mehdi_${DateTime.now().year}.pdf');
      expect(name, isNot(contains('/')));
      expect(name, isNot(contains(':')));
    });

    test('replaces spaces so the name stays one token', () {
      final name = service.fileName(
        resumeWith(
          language: ResumeLanguage.english,
          first: 'Mary Jane',
          last: 'Watson',
        ),
      );
      expect(name, 'Resume_Mary_Jane_${DateTime.now().year}.pdf');
    });
  });
}
