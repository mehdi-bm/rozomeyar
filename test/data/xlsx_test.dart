import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/data/excel/xlsx.dart';
import 'package:xml/xml.dart';

void main() {
  group('column names', () {
    test('maps indexes to spreadsheet letters', () {
      expect(Xlsx.columnName(0), 'A');
      expect(Xlsx.columnName(25), 'Z');
      expect(Xlsx.columnName(26), 'AA');
      expect(Xlsx.columnName(27), 'AB');
      expect(Xlsx.columnName(51), 'AZ');
      expect(Xlsx.columnName(52), 'BA');
      expect(Xlsx.columnName(701), 'ZZ');
      expect(Xlsx.columnName(702), 'AAA');
    });

    test('round-trips back to the index', () {
      for (final index in <int>[0, 1, 25, 26, 27, 51, 52, 700, 701, 702]) {
        expect(
          Xlsx.columnIndex('${Xlsx.columnName(index)}7'),
          index,
          reason: 'failed for index $index',
        );
      }
    });
  });

  group('round trip', () {
    test('preserves sheets, rows and cells', () {
      final source = <String, List<List<String>>>{
        'Meta': <List<String>>[
          <String>['key', 'value'],
          <String>['schemaVersion', '1'],
        ],
        'Experience': <List<String>>[
          <String>['jobTitle', 'company'],
          <String>['توسعه‌دهنده ارشد', 'شرکت نمونه'],
          <String>['Senior Developer', 'Example Co.'],
        ],
      };

      final decoded = Xlsx.decode(Xlsx.encode(source));

      expect(decoded.keys, <String>['Meta', 'Experience']);
      expect(decoded['Meta']![1], <String>['schemaVersion', '1']);
      expect(decoded['Experience']![1], <String>['توسعه‌دهنده ارشد', 'شرکت نمونه']);
    });

    test('keeps Persian text and digits exactly as written', () {
      const text = 'کاهش ۴۰ درصدی زمان بارگذاری — نیم‌فاصله و «گیومه»';
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[
            <String>[text],
          ],
        }),
      );
      expect(decoded['S']![0][0], text);
    });

    test('does not let a number-like string become a number', () {
      // Stored as an inline string, so "007" and a Jalali date survive intact.
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[
            <String>['007', '1400/05/20', '۱۴۰۰', '3.10'],
          ],
        }),
      );
      expect(decoded['S']![0], <String>['007', '1400/05/20', '۱۴۰۰', '3.10']);
    });

    test('escapes characters that would break the XML', () {
      const nasty = r'a < b & c > d "quoted" <tag/>';
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[
            <String>[nasty],
          ],
        }),
      );
      expect(decoded['S']![0][0], nasty);
    });

    test('preserves leading and trailing spaces', () {
      const padded = '  spaced  ';
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[
            <String>[padded],
          ],
        }),
      );
      expect(decoded['S']![0][0], padded);
    });

    test('handles empty cells and ragged rows', () {
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[
            <String>['a', '', 'c'],
            <String>['d'],
          ],
        }),
      );
      expect(decoded['S']![0], <String>['a', '', 'c']);
      // Rows are padded to the widest so callers can index safely.
      expect(decoded['S']![1], <String>['d', '', '']);
    });

    test('handles many columns, past the single-letter range', () {
      final wide = <String>[for (var i = 0; i < 30; i++) 'c$i'];
      final decoded = Xlsx.decode(
        Xlsx.encode(<String, List<List<String>>>{
          'S': <List<String>>[wide],
        }),
      );
      expect(decoded['S']![0], wide);
    });
  });

  group('file structure', () {
    late Archive archive;

    setUp(() {
      archive = ZipDecoder().decodeBytes(
        Xlsx.encode(<String, List<List<String>>>{
          'One': <List<String>>[
            <String>['x'],
          ],
          'Two': <List<String>>[
            <String>['y'],
          ],
        }),
      );
    });

    test('contains every part the OOXML package requires', () {
      final names = archive.files.map((f) => f.name).toSet();
      expect(names, containsAll(<String>[
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/_rels/workbook.xml.rels',
        'xl/styles.xml',
        'xl/worksheets/sheet1.xml',
        'xl/worksheets/sheet2.xml',
      ]));
    });

    test('every part is well-formed XML', () {
      for (final file in archive.files) {
        final content = utf8.decode(file.readBytes() ?? <int>[]);
        expect(
          () => XmlDocument.parse(content),
          returnsNormally,
          reason: '${file.name} is not valid XML',
        );
      }
    });

    test('declares a content type for each sheet', () {
      final types = XmlDocument.parse(
        utf8.decode(
          archive.files
                  .firstWhere((f) => f.name == '[Content_Types].xml')
                  .readBytes() ??
              <int>[],
        ),
      );
      final parts = types
          .findAllElements('Override')
          .map((e) => e.getAttribute('PartName'))
          .toSet();
      expect(parts, contains('/xl/worksheets/sheet1.xml'));
      expect(parts, contains('/xl/worksheets/sheet2.xml'));
      expect(parts, contains('/xl/styles.xml'));
    });

    test('each sheet relationship points at a part that exists', () {
      final rels = XmlDocument.parse(
        utf8.decode(
          archive.files
                  .firstWhere((f) => f.name == 'xl/_rels/workbook.xml.rels')
                  .readBytes() ??
              <int>[],
        ),
      );
      final names = archive.files.map((f) => f.name).toSet();
      for (final rel in rels.findAllElements('Relationship')) {
        final target = rel.getAttribute('Target')!;
        expect(
          names,
          contains('xl/$target'),
          reason: 'relationship target $target is missing from the package',
        );
      }
    });
  });

  group('failure handling', () {
    test('rejects an empty workbook', () {
      expect(
        () => Xlsx.encode(<String, List<List<String>>>{}),
        throwsArgumentError,
      );
    });

    test('rejects bytes that are not a zip at all', () {
      expect(
        () => Xlsx.decode(Uint8List.fromList(utf8.encode('not a zip'))),
        throwsA(isA<Object>()),
      );
    });

    test('rejects a zip that is not a workbook', () {
      final archive = Archive();
      final bytes = utf8.encode('hello');
      archive.addFile(ArchiveFile('readme.txt', bytes.length, bytes));
      final zip = Uint8List.fromList(ZipEncoder().encode(archive));

      expect(() => Xlsx.decode(zip), throwsA(isA<FormatException>()));
    });
  });
}
