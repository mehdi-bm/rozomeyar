import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../core/utils/app_failure.dart';
import '../domain/models/enums.dart';
import '../domain/models/resume.dart';
import 'pdf_fonts.dart';
import 'pdf_text.dart';
import 'pdf_theme.dart';
import 'templates/resume_template.dart';
import 'templates/template_registry.dart';

/// Turns a [Resume] into PDF bytes, a file, or a share sheet.
///
/// Kept entirely free of Flutter widgets so it can be unit-tested and reused
/// from anywhere.
class ResumePdfService {
  const ResumePdfService();

  Future<Uint8List> build(Resume resume) async {
    return guard(AppFailureKind.pdfGeneration, () async {
      final fonts = await PdfFonts.load();
      return buildWithFonts(resume, fonts);
    });
  }

  /// Separated from [build] so tests can supply fonts read from disk rather
  /// than through the asset bundle.
  Future<Uint8List> buildWithFonts(Resume source, PdfFonts fonts) async {
    // Strip invisible formatting characters before anything is laid out — see
    // `pdf_text.dart` for why they cannot reach the font layer.
    final resume = Resume.fromJson(
      pdfSafeJson(source.toJson())! as Map<String, dynamic>,
    );
    final template = TemplateRegistry.byId(resume.templateSettings.templateId);
    final theme = ResumePdfTheme(
      fonts: fonts,
      settings: resume.templateSettings,
      language: resume.language,
    );
    final photo = await _loadPhoto(resume, template);
    final data = ResumeRenderData(resume: resume, theme: theme, photo: photo);

    final document = pw.Document(
      title: resume.title,
      author: resume.personalInfo.fullName,
    );

    final format = template.pageFormat(theme);
    final background = template.background(data, format);
    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: template.margin(theme),
          textDirection: theme.textDirection,
          theme: theme.themeData,
          buildBackground: background == null ? null : (_) => background,
        ),
        // A resume that somehow exceeds this is a data problem, not a layout
        // one; the default of 20 is plenty and prevents runaway generation.
        maxPages: 20,
        build: (context) => template.build(data),
      ),
    );

    return document.save();
  }

  Future<pw.ImageProvider?> _loadPhoto(
    Resume resume,
    ResumeTemplate template,
  ) async {
    if (!template.supportsPhoto) return null;
    if (!resume.templateSettings.showProfilePhoto) return null;
    final path = resume.personalInfo.photoPath;
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return pw.MemoryImage(await file.readAsBytes());
    } catch (_) {
      // A missing or unreadable photo must never block the export.
      return null;
    }
  }

  /// `Resume_Mehdi_2026.pdf` / `رزومه_مهدی.pdf`
  String fileName(Resume resume) {
    final info = resume.personalInfo;
    final isPersian = resume.language == ResumeLanguage.persian;
    final first = _sanitize(info.firstName);
    final last = _sanitize(info.lastName);

    final namePart = <String>[
      first,
      if (first.isEmpty) last,
    ].where((part) => part.isNotEmpty).join('_');

    if (isPersian) {
      final base = namePart.isEmpty ? 'رزومه' : 'رزومه_$namePart';
      return '$base.pdf';
    }
    final year = DateTime.now().year;
    final base = namePart.isEmpty ? 'Resume' : 'Resume_$namePart';
    return '${base}_$year.pdf';
  }

  /// Strips characters that are illegal in filenames on Windows or Android and
  /// collapses whitespace to underscores.
  static String _sanitize(String value) {
    final cleaned = pdfSafe(value)
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned;
  }

  /// Writes to app-private storage — no storage permission is required, and the
  /// file is still shareable through a content URI.
  Future<File> saveToFile(Resume resume, Uint8List bytes) async {
    return guard(AppFailureKind.storageWrite, () async {
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(documents.path, 'exports'));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File(p.join(directory.path, fileName(resume)));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    });
  }

  Future<void> share(Resume resume, Uint8List bytes) async {
    return guard(AppFailureKind.share, () async {
      final file = await saveToFile(resume, bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
          subject: resume.title,
        ),
      );
    });
  }
}
