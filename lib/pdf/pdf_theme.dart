import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/models/enums.dart';
import '../domain/models/template_settings.dart';
import 'pdf_fonts.dart';
import 'pdf_labels.dart';

/// Everything a template needs to draw text: fonts, scaled styles, accent
/// colour, direction and in-document labels.
///
/// PDF templates intentionally stay light-on-white regardless of the app's dark
/// mode — a resume is a printable document, not a screen.
class ResumePdfTheme {
  ResumePdfTheme({
    required this.fonts,
    required this.settings,
    required this.language,
  }) : accent = PdfColor.fromInt(settings.accentColorValue),
       labels = PdfLabels.of(language),
       _scale = settings.fontScale.factor;

  final PdfFonts fonts;
  final TemplateSettings settings;
  final ResumeLanguage language;
  final PdfColor accent;
  final PdfLabels labels;
  final double _scale;

  static const PdfColor ink = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor muted = PdfColor.fromInt(0xFF5C5C5C);
  static const PdfColor hairline = PdfColor.fromInt(0xFFD8D8D8);
  static const PdfColor sidebarBackground = PdfColor.fromInt(0xFFF2F4F8);

  bool get isRtl => language.isRtl;

  pw.TextDirection get textDirection =>
      isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  double size(double base) => base * _scale;

  /// Baseline theme applied to the whole document so every widget inherits a
  /// font that can render Persian.
  pw.ThemeData get themeData => pw.ThemeData.withFont(
    base: fonts.regular,
    bold: fonts.bold,
  ).copyWith(defaultTextStyle: body);

  pw.TextStyle get name => pw.TextStyle(
    font: fonts.bold,
    fontSize: size(22),
    color: ink,
    lineSpacing: 1.5,
  );

  pw.TextStyle get jobTitle => pw.TextStyle(
    font: fonts.medium,
    fontSize: size(12.5),
    color: accent,
    lineSpacing: 1.5,
  );

  pw.TextStyle get sectionHeading => pw.TextStyle(
    font: fonts.bold,
    fontSize: size(11.5),
    color: accent,
    letterSpacing: isRtl ? 0 : 0.4,
  );

  pw.TextStyle get itemTitle =>
      pw.TextStyle(font: fonts.bold, fontSize: size(10.5), color: ink);

  pw.TextStyle get itemSubtitle =>
      pw.TextStyle(font: fonts.medium, fontSize: size(9.5), color: accent);

  pw.TextStyle get body => pw.TextStyle(
    font: fonts.regular,
    fontSize: size(9.5),
    color: ink,
    lineSpacing: 2.2,
  );

  pw.TextStyle get meta =>
      pw.TextStyle(font: fonts.regular, fontSize: size(8.5), color: muted);

  pw.TextStyle get contact =>
      pw.TextStyle(font: fonts.regular, fontSize: size(9), color: ink);

  /// Sidebar variants for the Modern template's tinted column.
  pw.TextStyle get sidebarHeading =>
      pw.TextStyle(font: fonts.bold, fontSize: size(10.5), color: accent);

  pw.TextStyle get sidebarBody => pw.TextStyle(
    font: fonts.regular,
    fontSize: size(9),
    color: ink,
    lineSpacing: 2,
  );
}
