import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/src/pdf/font/bidi_utils.dart' as bidi;
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';
import 'package:resumeyar/pdf/pdf_labels.dart';
import 'package:resumeyar/pdf/pdf_text.dart';

void main() {
  group('pdfSafe', () {
    test('replaces a half-space with a space so shaping stays correct', () {
      expect(pdfSafe('نرم‌افزار'), 'نرم افزار');
      expect(pdfSafe('توسعه‌دهنده'), 'توسعه دهنده');
    });

    test('drops the other invisible formatting characters outright', () {
      expect(pdfSafe('a​b'), 'ab'); // ZWSP
      expect(pdfSafe('a‍b'), 'ab'); // ZWJ
      expect(pdfSafe('a‎b'), 'ab'); // LRM
      expect(pdfSafe('a‏b'), 'ab'); // RLM
      expect(pdfSafe('a؜b'), 'ab'); // ALM
      expect(pdfSafe('a﻿b'), 'ab'); // BOM
    });

    test('collapses the double space a substitution can create', () {
      expect(pdfSafe('نرم ‌ افزار'), 'نرم افزار');
    });

    test('leaves ordinary text untouched', () {
      const text = 'Senior Software Developer — تهران، ایران';
      expect(pdfSafe(text), same(text));
    });

    test('leaves an empty string alone', () {
      expect(pdfSafe(''), '');
    });
  });

  group('pdfSafeJson', () {
    test('sanitises strings at every depth', () {
      final result = pdfSafeJson(<String, dynamic>{
        'a': 'مهارت‌ها',
        'b': <dynamic>[
          'زبان‌ها',
          <String, dynamic>{'c': 'پروژه‌ها'},
        ],
        'n': 42,
        'z': null,
      });

      expect(result, <String, dynamic>{
        'a': 'مهارت ها',
        'b': <dynamic>[
          'زبان ها',
          <String, dynamic>{'c': 'پروژه ها'},
        ],
        'n': 42,
        'z': null,
      });
    });
  });

  group('regression: nothing invisible reaches the font', () {
    /// The characters that render as stray boxes because `readGlyph` misreads
    /// zero-length glyphs.
    const dangerous = <int>[
      0x200B,
      0x200C,
      0x200D,
      0x200E,
      0x200F,
      0x061C,
      0xFEFF,
    ];

    void expectClean(String value, String context) {
      // Check the shaped form too — shaping is what actually feeds the font.
      for (final text in <String>[value, bidi.logicalToVisual(value)]) {
        for (final rune in text.runes) {
          expect(
            dangerous.contains(rune),
            isFalse,
            reason:
                '$context still contains '
                'U+${rune.toRadixString(16).toUpperCase()}',
          );
        }
      }
    }

    test('sample resume text is clean after sanitising', () {
      for (final language in ResumeLanguage.values) {
        final raw = SampleResume.build(language: language);
        final safe = pdfSafeJson(raw.toJson())! as Map<String, dynamic>;

        void walk(Object? value, String path) {
          if (value is String) {
            expectClean(value, '${language.name}:$path');
          } else if (value is Map<String, dynamic>) {
            value.forEach((key, v) => walk(v, '$path.$key'));
          } else if (value is List) {
            for (var i = 0; i < value.length; i++) {
              walk(value[i], '$path[$i]');
            }
          }
        }

        walk(safe, 'resume');
      }
    });

    test('section headings are clean in both languages', () {
      for (final language in ResumeLanguage.values) {
        final labels = PdfLabels.of(language);
        for (final heading in <String>[
          labels.summary,
          labels.experience,
          labels.education,
          labels.skills,
          labels.languages,
          labels.projects,
          labels.certifications,
          labels.links,
          labels.contact,
          labels.present,
          labels.technologies,
          ...labels.skillLevels.values,
          ...labels.languageLevels.values,
        ]) {
          expectClean(heading, '${language.name} heading "$heading"');
        }
      }
    });

    test('the Persian headings that need a half-space still read correctly', () {
      final labels = PdfLabels.of(ResumeLanguage.persian);
      expect(labels.skills, 'مهارت ها');
      expect(labels.languages, 'زبان ها');
      expect(labels.skillLevels[SkillLevel.expert], 'حرفه ای');
    });
  });
}
