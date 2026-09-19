import 'dart:io';
import 'dart:typed_data';

import 'package:resumeyar/pdf/pdf_fonts.dart';

/// Loads the Vazirmatn TTFs straight from disk.
///
/// `PdfFonts.load()` goes through the asset bundle, which is not available in a
/// plain `test()`, so tests read the same files directly instead.
PdfFonts loadTestFonts() {
  Uint8List read(String weight) =>
      File('assets/fonts/Vazirmatn/Vazirmatn-$weight.ttf').readAsBytesSync();

  return PdfFonts.fromBytes(
    light: read('Light'),
    regular: read('Regular'),
    medium: read('Medium'),
    bold: read('Bold'),
  );
}
