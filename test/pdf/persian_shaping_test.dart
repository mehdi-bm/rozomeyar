import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// Reaching into the pdf package's internals is deliberate: these are the exact
// functions `pw.Text` uses for RTL, so testing them is testing what the
// generated document will actually contain.
import 'package:pdf/src/pdf/font/bidi_utils.dart' as bidi;
import 'package:pdf/src/pdf/font/ttf_parser.dart';

void main() {
  late TtfParser regular;

  setUpAll(() {
    regular = TtfParser(
      File('assets/fonts/Vazirmatn/Vazirmatn-Regular.ttf')
          .readAsBytesSync()
          .buffer
          .asByteData(),
    );
  });

  /// Every codepoint the shaper produces must map to a real glyph; glyph 0 is
  /// `.notdef`, which is what renders as a blank box.
  Set<String> missingGlyphsFor(String text, TtfParser font) {
    final missing = <String>{};
    for (final rune in bidi.logicalToVisual(text).runes) {
      final gid = font.charToGlyphIndexMap[rune];
      if (gid == null || gid == 0) {
        missing.add('U+${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}');
      }
    }
    return missing;
  }

  group('glyph coverage', () {
    const samples = <String>[
      'مهدی محمدی',
      'توسعه‌دهنده ارشد نرم‌افزار',
      'خلاصه‌ای کوتاه درباره تجربه، تخصص و اهداف حرفه‌ای.',
      'شرکت نمونه | ۱۴۰۰ - تاکنون',
      'کارشناسی مهندسی نرم‌افزار، دانشگاه تهران',
      'مهارت‌ها: Flutter، ASP.NET Core و SQL Server',
      'زبان‌ها: انگلیسی (پیشرفته)، فارسی (زبان مادری)',
      'گواهینامه‌ها و دوره‌ها',
      'آدرس: تهران، ایران',
      'وضعیت تأهل: مجرد',
      'ژ ژاله، چ چای، گ گل، پ پرواز',
      '۰۱۲۳۴۵۶۷۸۹ ٪ ﷼',
    ];

    for (final sample in samples) {
      test('Vazirmatn renders "$sample"', () {
        expect(missingGlyphsFor(sample, regular), isEmpty);
      });
    }

    test('every bundled weight covers Persian text', () {
      for (final weight in <String>['Light', 'Medium', 'Bold']) {
        final font = TtfParser(
          File('assets/fonts/Vazirmatn/Vazirmatn-$weight.ttf')
              .readAsBytesSync()
              .buffer
              .asByteData(),
        );
        expect(
          missingGlyphsFor('توسعه‌دهنده ارشد نرم‌افزار', font),
          isEmpty,
          reason: '$weight is missing glyphs',
        );
      }
    });
  });

  group('letter joining', () {
    test('connects letters instead of leaving them isolated', () {
      // "بب": the leading BEH must take a joined form, not its isolated one.
      final codes = bidi.logicalToVisual('بب').runes.toList();

      expect(
        codes.every((c) => c >= 0xFB50 && c <= 0xFEFF),
        isTrue,
        reason: 'expected presentation forms, got '
            '${codes.map((c) => c.toRadixString(16)).toList()}',
      );
      expect(
        codes.any((c) => c == 0xFE91 || c == 0xFE92),
        isTrue,
        reason: 'expected a joined BEH form, got '
            '${codes.map((c) => c.toRadixString(16)).toList()}',
      );
      // FE8F is the isolated BEH; a letter that joins must not use it.
      expect(codes, isNot(contains(0xFE8F)));
    });

    test('a letter that never joins forwards stays isolated', () {
      // ALEF does not connect to the letter after it, so the BEH in "اب"
      // keeps its isolated form (FE8F) and ALEF keeps its own (FE8D).
      final codes = bidi.logicalToVisual('اب').runes.toList();
      expect(codes, <int>[0xFE8F, 0xFE8D]);
    });
  });

  // How the `pdf` package renders RTL, because the intermediate string looks
  // wrong out of context:
  //
  //   1. `logicalToVisual` runs the Unicode bidi algorithm, which reverses the
  //      whole paragraph, then reverses *word order* back. The result is words
  //      in logical order with each word's characters in visual order.
  //   2. At layout time `_Line.realign` mirrors every span's x position within
  //      its line when textDirection is rtl.
  //
  // Step 2 undoes the word-level ordering of step 1, so the page reads
  // correctly — and because the mirroring is per line, paragraphs that wrap
  // across several lines still read in the right order.
  group('visual ordering', () {
    test('characters within a word are emitted in visual order', () {
      // "ماه" — logically م ا ه. Each character is shaped and the sequence is
      // reversed: isolated HEH, final ALEF, initial MEEM.
      final codes = bidi.logicalToVisual('ماه').runes.toList();
      expect(codes, <int>[0xFEE9, 0xFE8E, 0xFEE3]);
    });

    test('word order is preserved, so wrapped paragraphs read correctly', () {
      // Each word is shaped and character-reversed, but the first logical word
      // still comes first — layout mirroring places it on the right.
      final first = bidi.logicalToVisual('سلام');
      final both = bidi.logicalToVisual('سلام دنیا');

      expect(
        both.startsWith(first),
        isTrue,
        reason: 'expected "$both" to start with the first word "$first"',
      );
    });

    test('a Latin word inside Persian text is not character-reversed', () {
      final visual = bidi.logicalToVisual('مهارت Flutter است');
      expect(
        visual.contains('Flutter'),
        isTrue,
        reason: 'Latin must not be reversed, got: $visual',
      );
    });

    test('digits keep their order inside RTL text', () {
      final visual = bidi.logicalToVisual('سال 1400 بود');
      expect(visual.contains('1400'), isTrue, reason: 'got: $visual');
    });

    test('a multi-word Latin phrase keeps each word intact', () {
      // Word order here is flipped by step 1 and flipped back by step 2; what
      // matters at this level is that no word is mangled internally.
      final visual = bidi.logicalToVisual('Senior Software Developer');
      expect(visual.split(' ').toSet(), <String>{
        'Senior',
        'Software',
        'Developer',
      });
    });
  });
}
