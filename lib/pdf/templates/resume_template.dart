import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/enums.dart';
import '../../domain/models/resume.dart';
import '../pdf_theme.dart';

/// Everything a template needs to draw one resume.
class ResumeRenderData {
  const ResumeRenderData({
    required this.resume,
    required this.theme,
    this.photo,
  });

  final Resume resume;
  final ResumePdfTheme theme;

  /// Pre-decoded profile photo, or null when there is none or the template
  /// does not use one.
  final pw.ImageProvider? photo;

  bool get showPhoto => photo != null;
}

/// A resume layout. Templates return the flowing children of a
/// [pw.MultiPage] so long resumes paginate instead of being clipped.
abstract class ResumeTemplate {
  const ResumeTemplate();

  TemplateId get id;

  /// Whether the profile photo has a place in this layout. Classic and Minimal
  /// are text-only by design, so the photo toggle is disabled for them.
  bool get supportsPhoto;

  /// Reserved for a future paid tier; every template is free in V1.
  bool get isPro => false;

  PdfPageFormat pageFormat(ResumePdfTheme theme) => PdfPageFormat.a4;

  pw.EdgeInsets margin(ResumePdfTheme theme);

  /// Optional background painted on every page.
  ///
  /// `MultiPage` positions this itself — at the left margin for LTR, and at
  /// `margin.left + (availableWidth - childWidth)` for RTL — so the widget must
  /// declare an explicit width, otherwise it fills the page and lands in the
  /// wrong place.
  pw.Widget? background(ResumeRenderData data, PdfPageFormat format) => null;

  List<pw.Widget> build(ResumeRenderData data);
}
