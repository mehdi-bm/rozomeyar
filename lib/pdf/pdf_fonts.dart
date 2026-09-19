import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Embedded font set for generated PDFs.
///
/// Vazirmatn covers both Persian and Latin, so a mixed-script resume
/// ("Flutter و SQL Server") renders in one consistent typeface. The `pdf`
/// package shapes Arabic script into presentation forms and Vazirmatn provides
/// glyphs for all of them — verified by `test/pdf/persian_shaping_test.dart`.
class PdfFonts {
  const PdfFonts({
    required this.light,
    required this.regular,
    required this.medium,
    required this.bold,
  });

  final pw.Font light;
  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;

  static const String _base = 'assets/fonts/Vazirmatn';

  /// Parsing five TTFs takes long enough to be worth doing exactly once; every
  /// later export and preview reuses this future.
  static Future<PdfFonts>? _cached;

  static Future<PdfFonts> load() {
    return _cached ??= _loadFromAssets();
  }

  static Future<PdfFonts> _loadFromAssets() async {
    Future<pw.Font> font(String weight) async {
      final data = await rootBundle.load('$_base/Vazirmatn-$weight.ttf');
      return pw.Font.ttf(data);
    }

    return PdfFonts(
      light: await font('Light'),
      regular: await font('Regular'),
      medium: await font('Medium'),
      bold: await font('Bold'),
    );
  }

  /// Used by tests, which read the TTFs from disk instead of the asset bundle.
  factory PdfFonts.fromBytes({
    required Uint8List light,
    required Uint8List regular,
    required Uint8List medium,
    required Uint8List bold,
  }) {
    return PdfFonts(
      light: pw.Font.ttf(light.buffer.asByteData()),
      regular: pw.Font.ttf(regular.buffer.asByteData()),
      medium: pw.Font.ttf(medium.buffer.asByteData()),
      bold: pw.Font.ttf(bold.buffer.asByteData()),
    );
  }
}
