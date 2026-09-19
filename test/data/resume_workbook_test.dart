import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/data/excel/resume_workbook.dart';
import 'package:resumeyar/data/excel/xlsx.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/domain/models/skill.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';

void main() {
  Resume roundTrip(Resume resume) =>
      ResumeWorkbook.decode(ResumeWorkbook.encode(resume));

  group('round trip', () {
    for (final language in ResumeLanguage.values) {
      test('preserves the ${language.name} sample resume', () {
        final source = SampleResume.build(language: language);
        final result = roundTrip(source);

        expect(result.language, source.language);
        expect(result.professionalSummary, source.professionalSummary);
        expect(result.personalInfo.firstName, source.personalInfo.firstName);
        expect(result.personalInfo.lastName, source.personalInfo.lastName);
        expect(result.personalInfo.jobTitle, source.personalInfo.jobTitle);
        expect(result.personalInfo.email, source.personalInfo.email);
        expect(result.personalInfo.mobile, source.personalInfo.mobile);
        expect(result.templateSettings, source.templateSettings);
      });
    }

    test('preserves every section item and its fields', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final result = roundTrip(source);

      expect(result.experiences, hasLength(source.experiences.length));
      expect(result.educations, hasLength(source.educations.length));
      expect(result.skills, hasLength(source.skills.length));
      expect(result.languages, hasLength(source.languages.length));
      expect(result.projects, hasLength(source.projects.length));
      expect(result.certifications, hasLength(source.certifications.length));
      expect(result.links, hasLength(source.links.length));

      final sourceExperience = source.experiences.first;
      final resultExperience = result.experiences.first;
      expect(resultExperience.jobTitle, sourceExperience.jobTitle);
      expect(resultExperience.company, sourceExperience.company);
      expect(resultExperience.city, sourceExperience.city);
      expect(resultExperience.startDate, sourceExperience.startDate);
      expect(resultExperience.isCurrent, sourceExperience.isCurrent);
      expect(resultExperience.description, sourceExperience.description);
      expect(resultExperience.achievements, sourceExperience.achievements);
    });

    test('preserves multi-line achievements', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final result = roundTrip(source);

      expect(
        result.experiences.first.achievementLines,
        source.experiences.first.achievementLines,
      );
      expect(result.experiences.first.achievementLines.length, 3);
    });

    test('preserves enum values including a null skill level', () {
      final source = SampleResume.build(language: ResumeLanguage.persian)
          .copyWith(
        skills: <Skill>[
          const Skill(id: 'a', name: 'Flutter', level: SkillLevel.expert),
          const Skill(id: 'b', name: 'Rust'),
        ],
      );

      final result = roundTrip(source);
      expect(result.skills[0].level, SkillLevel.expert);
      expect(result.skills[1].level, isNull);
    });

    test('preserves optional-field visibility switches', () {
      final source = SampleResume.build(language: ResumeLanguage.persian)
          .copyWith(
        personalInfo: const PersonalInfo(
          firstName: 'a',
          lastName: 'b',
          address: 'خیابان نمونه',
          maritalStatus: MaritalStatus.married,
          visibility: OptionalFieldVisibility(
            showDateOfBirth: true,
            showAddress: false,
            showMaritalStatus: true,
          ),
        ),
      );

      final result = roundTrip(source);
      expect(result.personalInfo.visibility.showDateOfBirth, isTrue);
      expect(result.personalInfo.visibility.showAddress, isFalse);
      expect(result.personalInfo.visibility.showMaritalStatus, isTrue);
      expect(result.personalInfo.maritalStatus, MaritalStatus.married);
    });

    test('preserves an empty resume without inventing entries', () {
      final now = DateTime(2026, 1, 1);
      final result = roundTrip(
        Resume(
          id: 'x',
          title: 'خالی',
          createdAt: now,
          updatedAt: now,
          personalInfo: const PersonalInfo(firstName: 'علی', lastName: 'ر'),
        ),
      );

      expect(result.experiences, isEmpty);
      expect(result.skills, isEmpty);
      expect(result.links, isEmpty);
      expect(result.personalInfo.firstName, 'علی');
    });
  });

  group('import safety', () {
    test('always assigns a new id so nothing is overwritten', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final first = roundTrip(source);
      final second = roundTrip(source);

      expect(first.id, isNot(source.id));
      expect(first.id, isNot(second.id));
    });

    test('section item ids are regenerated and stay unique', () {
      final result = roundTrip(
        SampleResume.build(language: ResumeLanguage.persian),
      );
      final ids = <String>[
        ...result.experiences.map((e) => e.id),
        ...result.skills.map((e) => e.id),
        ...result.links.map((e) => e.id),
      ];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('an imported resume is never flagged as the built-in sample', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      expect(source.isSample, isTrue);
      expect(roundTrip(source).isSample, isFalse);
    });

    test('the photo is documented as not restorable', () {
      final source = SampleResume.build(language: ResumeLanguage.persian)
          .copyWith(
        personalInfo: const PersonalInfo(
          firstName: 'a',
          lastName: 'b',
          photoPath: r'C:\photos\me.jpg',
        ),
      );

      // A cell cannot hold an image, so the path deliberately does not survive
      // rather than pointing at a file that may not exist on the new device.
      expect(roundTrip(source).personalInfo.photoPath, isNull);
    });
  });

  group('rejecting bad input', () {
    test('rejects a workbook that is not a resume backup', () {
      final foreign = Xlsx.encode(<String, List<List<String>>>{
        'Sheet1': <List<String>>[
          <String>['some', 'other', 'file'],
        ],
      });

      expect(
        () => ResumeWorkbook.decode(foreign),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects bytes that are not a workbook at all', () {
      expect(
        () => ResumeWorkbook.decode(Uint8List.fromList(<int>[1, 2, 3, 4])),
        throwsA(isA<Object>()),
      );
    });

    test('ignores blank trailing rows left behind by an editor', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final sheets = Xlsx.decode(ResumeWorkbook.encode(source));

      final skills = sheets['Skills']!;
      final width = skills.first.length;
      skills.addAll(<List<String>>[
        <String>[for (var i = 0; i < width; i++) ''],
        <String>[for (var i = 0; i < width; i++) '   '],
      ]);

      final result = ResumeWorkbook.decode(Xlsx.encode(sheets));
      expect(result.skills, hasLength(source.skills.length));
    });

    test('survives a sheet the user deleted in Excel', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final sheets = Xlsx.decode(ResumeWorkbook.encode(source))
        ..remove('Projects')
        ..remove('Links');

      final result = ResumeWorkbook.decode(Xlsx.encode(sheets));
      expect(result.projects, isEmpty);
      expect(result.links, isEmpty);
      // The rest still came through.
      expect(result.skills, hasLength(source.skills.length));
    });

    test('accepts rows edited by hand with unknown enum text', () {
      final source = SampleResume.build(language: ResumeLanguage.persian);
      final sheets = Xlsx.decode(ResumeWorkbook.encode(source));
      // Someone types a level that is not one of ours.
      sheets['Skills']![1][1] = 'wizard';

      final result = ResumeWorkbook.decode(Xlsx.encode(sheets));
      expect(result.skills.first.level, isNull);
      expect(result.skills.first.name, source.skills.first.name);
    });
  });
}
