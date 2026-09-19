import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// A minimal `.xlsx` reader/writer.
///
/// Written by hand rather than pulled from a package because every spreadsheet
/// package on pub either conflicts with this project or cannot do both halves:
/// `excel` is pinned to `archive ^3` and `xml <7` while `pdf` requires
/// `archive ^4` and `xml ^7`; `syncfusion_flutter_xlsio` is write-only and
/// commercially licensed; `spreadsheet_decoder` is read-only and stale.
/// `archive` and `xml` are already in the dependency tree, so this adds nothing.
///
/// Only what a resume backup needs is supported: multiple sheets of plain text
/// cells. Everything is written as an inline string, which avoids the shared
/// string table entirely and means numbers and dates round-trip as the exact
/// text that was written — important, because a resume holds Persian digits and
/// Jalali dates that Excel must not "helpfully" reinterpret.
abstract final class Xlsx {
  static const String _pkgRels =
      'http://schemas.openxmlformats.org/package/2006/relationships';
  static const String _docRels =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  static const String _mainNs =
      'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
  static const String _contentTypesNs =
      'http://schemas.openxmlformats.org/package/2006/content-types';

  /// Converts a zero-based column index to its spreadsheet letters (0 -> A,
  /// 26 -> AA).
  static String columnName(int index) {
    var remaining = index;
    final buffer = StringBuffer();
    while (true) {
      buffer.write(String.fromCharCode(65 + remaining % 26));
      remaining = remaining ~/ 26 - 1;
      if (remaining < 0) break;
    }
    return String.fromCharCodes(buffer.toString().codeUnits.reversed);
  }

  /// Parses "BC12" into a zero-based column index.
  static int columnIndex(String reference) {
    var index = 0;
    for (final unit in reference.codeUnits) {
      if (unit < 65 || unit > 90) break;
      index = index * 26 + (unit - 64);
    }
    return index - 1;
  }

  static Uint8List encode(Map<String, List<List<String>>> sheets) {
    if (sheets.isEmpty) {
      throw ArgumentError('a workbook needs at least one sheet');
    }
    final names = sheets.keys.toList();
    final archive = Archive();

    void add(String path, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(path, bytes.length, bytes));
    }

    add('[Content_Types].xml', _contentTypes(names.length));
    add('_rels/.rels', _rootRels());
    add('xl/workbook.xml', _workbook(names));
    add('xl/_rels/workbook.xml.rels', _workbookRels(names.length));
    add('xl/styles.xml', _styles());
    for (var i = 0; i < names.length; i++) {
      add('xl/worksheets/sheet${i + 1}.xml', _sheet(sheets[names[i]]!));
    }

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  /// Returns sheet name -> rows of cells. Missing cells become empty strings so
  /// every row in a sheet has the same length.
  static Map<String, List<List<String>>> decode(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? file(String path) {
      for (final entry in archive.files) {
        if (entry.name == path) return entry;
      }
      return null;
    }

    String read(String path) {
      final entry = file(path);
      if (entry == null) throw const FormatException('not a valid xlsx file');
      return utf8.decode(entry.readBytes() ?? <int>[]);
    }

    final workbook = XmlDocument.parse(read('xl/workbook.xml'));
    final rels = XmlDocument.parse(read('xl/_rels/workbook.xml.rels'));

    final targets = <String, String>{};
    for (final rel in rels.findAllElements('Relationship')) {
      targets[rel.getAttribute('Id') ?? ''] = rel.getAttribute('Target') ?? '';
    }

    final result = <String, List<List<String>>>{};
    for (final sheet in workbook.findAllElements('sheet')) {
      final name = sheet.getAttribute('name') ?? '';
      final id = sheet.getAttribute('r:id') ?? '';
      var target = targets[id] ?? '';
      if (target.isEmpty) continue;
      if (!target.startsWith('xl/')) target = 'xl/$target';
      final entry = file(target);
      if (entry == null) continue;
      result[name] = _parseSheet(utf8.decode(entry.readBytes() ?? <int>[]));
    }
    return result;
  }

  static List<List<String>> _parseSheet(String xml) {
    final document = XmlDocument.parse(xml);
    final rows = <List<String>>[];

    for (final row in document.findAllElements('row')) {
      final cells = <int, String>{};
      var maxIndex = -1;
      for (final cell in row.findElements('c')) {
        final reference = cell.getAttribute('r') ?? '';
        final index = reference.isEmpty ? cells.length : columnIndex(reference);
        if (index < 0) continue;
        cells[index] = _cellText(cell);
        if (index > maxIndex) maxIndex = index;
      }
      rows.add(<String>[
        for (var i = 0; i <= maxIndex; i++) cells[i] ?? '',
      ]);
    }

    // Pad every row to the widest, so callers can index without bounds checks.
    final width = rows.fold<int>(0, (max, row) => row.length > max ? row.length : max);
    for (final row in rows) {
      while (row.length < width) {
        row.add('');
      }
    }
    return rows;
  }

  static String _cellText(XmlElement cell) {
    // Inline strings are what this writer produces...
    final inline = cell.getElement('is');
    if (inline != null) {
      return inline.findAllElements('t').map((t) => t.innerText).join();
    }
    // ...but a file edited and re-saved by Excel may come back as a plain
    // value, so that form is accepted too.
    final value = cell.getElement('v');
    return value?.innerText ?? '';
  }

  static String _contentTypes(int sheetCount) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'Types',
      attributes: <String, String>{'xmlns': _contentTypesNs},
      nest: () {
        builder.element(
          'Default',
          attributes: <String, String>{
            'Extension': 'rels',
            'ContentType':
                'application/vnd.openxmlformats-package.relationships+xml',
          },
        );
        builder.element(
          'Default',
          attributes: <String, String>{
            'Extension': 'xml',
            'ContentType': 'application/xml',
          },
        );
        builder.element(
          'Override',
          attributes: <String, String>{
            'PartName': '/xl/workbook.xml',
            'ContentType': 'application/vnd.openxmlformats-officedocument'
                '.spreadsheetml.sheet.main+xml',
          },
        );
        builder.element(
          'Override',
          attributes: <String, String>{
            'PartName': '/xl/styles.xml',
            'ContentType': 'application/vnd.openxmlformats-officedocument'
                '.spreadsheetml.styles+xml',
          },
        );
        for (var i = 1; i <= sheetCount; i++) {
          builder.element(
            'Override',
            attributes: <String, String>{
              'PartName': '/xl/worksheets/sheet$i.xml',
              'ContentType': 'application/vnd.openxmlformats-officedocument'
                  '.spreadsheetml.worksheet+xml',
            },
          );
        }
      },
    );
    return builder.buildDocument().toXmlString();
  }

  static String _rootRels() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'Relationships',
      attributes: <String, String>{'xmlns': _pkgRels},
      nest: () {
        builder.element(
          'Relationship',
          attributes: <String, String>{
            'Id': 'rId1',
            'Type': '$_docRels/officeDocument',
            'Target': 'xl/workbook.xml',
          },
        );
      },
    );
    return builder.buildDocument().toXmlString();
  }

  static String _workbook(List<String> names) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'workbook',
      attributes: <String, String>{'xmlns': _mainNs, 'xmlns:r': _docRels},
      nest: () {
        builder.element(
          'sheets',
          nest: () {
            for (var i = 0; i < names.length; i++) {
              builder.element(
                'sheet',
                attributes: <String, String>{
                  'name': names[i],
                  'sheetId': '${i + 1}',
                  'r:id': 'rId${i + 1}',
                },
              );
            }
          },
        );
      },
    );
    return builder.buildDocument().toXmlString();
  }

  static String _workbookRels(int sheetCount) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'Relationships',
      attributes: <String, String>{'xmlns': _pkgRels},
      nest: () {
        for (var i = 1; i <= sheetCount; i++) {
          builder.element(
            'Relationship',
            attributes: <String, String>{
              'Id': 'rId$i',
              'Type': '$_docRels/worksheet',
              'Target': 'worksheets/sheet$i.xml',
            },
          );
        }
        builder.element(
          'Relationship',
          attributes: <String, String>{
            'Id': 'rId${sheetCount + 1}',
            'Type': '$_docRels/styles',
            'Target': 'styles.xml',
          },
        );
      },
    );
    return builder.buildDocument().toXmlString();
  }

  /// Excel tolerates a missing styles part in practice, but some readers do
  /// not, so a minimal valid one is always written.
  static String _styles() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'styleSheet',
      attributes: <String, String>{'xmlns': _mainNs},
      nest: () {
        builder.element('fonts', attributes: <String, String>{'count': '1'},
            nest: () {
          builder.element('font');
        });
        builder.element('fills', attributes: <String, String>{'count': '1'},
            nest: () {
          builder.element('fill', nest: () {
            builder.element('patternFill',
                attributes: <String, String>{'patternType': 'none'});
          });
        });
        builder.element('borders', attributes: <String, String>{'count': '1'},
            nest: () {
          builder.element('border');
        });
        builder.element('cellStyleXfs',
            attributes: <String, String>{'count': '1'}, nest: () {
          builder.element('xf',
              attributes: <String, String>{
                'numFmtId': '0',
                'fontId': '0',
                'fillId': '0',
                'borderId': '0',
              });
        });
        builder.element('cellXfs', attributes: <String, String>{'count': '1'},
            nest: () {
          builder.element('xf',
              attributes: <String, String>{
                'numFmtId': '0',
                'fontId': '0',
                'fillId': '0',
                'borderId': '0',
                'xfId': '0',
              });
        });
      },
    );
    return builder.buildDocument().toXmlString();
  }

  static String _sheet(List<List<String>> rows) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    builder.element(
      'worksheet',
      attributes: <String, String>{'xmlns': _mainNs},
      nest: () {
        builder.element(
          'sheetData',
          nest: () {
            for (var r = 0; r < rows.length; r++) {
              builder.element(
                'row',
                attributes: <String, String>{'r': '${r + 1}'},
                nest: () {
                  final row = rows[r];
                  for (var c = 0; c < row.length; c++) {
                    if (row[c].isEmpty) continue;
                    builder.element(
                      'c',
                      attributes: <String, String>{
                        'r': '${columnName(c)}${r + 1}',
                        't': 'inlineStr',
                      },
                      nest: () {
                        builder.element(
                          'is',
                          nest: () {
                            builder.element(
                              't',
                              attributes: <String, String>{
                                // Keeps leading/trailing spaces intact.
                                'xml:space': 'preserve',
                              },
                              nest: () => builder.text(row[c]),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              );
            }
          },
        );
      },
    );
    return builder.buildDocument().toXmlString();
  }
}
