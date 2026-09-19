import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/enums.dart';
import '../pdf_theme.dart';
import 'pdf_blocks.dart';
import 'resume_template.dart';

/// Two-column layout with a tinted sidebar for the photo, contact details,
/// skills, languages and links.
///
/// The columns are built with [pw.Partitions], whose children are spanning
/// widgets — so unlike a plain `Row`, a long resume flows onto further pages
/// instead of being clipped. The sidebar sits on the right for RTL resumes and
/// on the left for LTR ones; `Partitions` lays children out left-to-right
/// regardless of text direction, so the order is chosen explicitly.
class ModernTemplate extends ResumeTemplate {
  const ModernTemplate();

  static const double _sidebarWidth = 168;
  static const double _gutter = 18;
  static const double _pageMargin = 32;

  @override
  TemplateId get id => TemplateId.modern;

  @override
  bool get supportsPhoto => true;

  @override
  pw.EdgeInsets margin(ResumePdfTheme theme) =>
      const pw.EdgeInsets.fromLTRB(
        _pageMargin,
        _pageMargin,
        _pageMargin,
        _pageMargin,
      );

  /// Tinted panel behind the sidebar, repeated on every page so a multi-page
  /// resume keeps the two-column look.
  ///
  /// Width and height are both explicit: `MultiPage` paints this at the bottom
  /// margin and mirrors its x position for RTL using the child's own width, so
  /// an unsized child would be misplaced and would overrun the page.
  @override
  pw.Widget background(ResumeRenderData data, PdfPageFormat format) {
    return pw.Container(
      width: _sidebarWidth + _gutter / 2,
      height: format.height - _pageMargin * 2,
      decoration: pw.BoxDecoration(
        color: ResumePdfTheme.sidebarBackground,
        borderRadius: pw.BorderRadius.circular(6),
      ),
    );
  }

  @override
  List<pw.Widget> build(ResumeRenderData data) {
    final theme = data.theme;
    final sidebar = pw.Partition(
      width: _sidebarWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: _sidebarChildren(data),
      ),
    );
    final main = pw.Partition(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: _mainChildren(data),
      ),
    );

    return <pw.Widget>[
      pw.Partitions(
        children: theme.isRtl
            ? <pw.Partition>[main, _spacer(), sidebar]
            : <pw.Partition>[sidebar, _spacer(), main],
      ),
    ];
  }

  pw.Partition _spacer() =>
      pw.Partition(width: _gutter, child: pw.Column(children: <pw.Widget>[]));

  List<pw.Widget> _sidebarChildren(ResumeRenderData data) {
    final resume = data.resume;
    final theme = data.theme;
    final labels = theme.labels;
    final info = resume.personalInfo;
    final padding = const pw.EdgeInsets.only(right: 12, left: 12);

    pw.Widget pad(pw.Widget child) =>
        pw.Padding(padding: padding, child: child);

    return <pw.Widget>[
      if (data.showPhoto) ...<pw.Widget>[
        pw.SizedBox(height: 6),
        pad(
          pw.Center(child: PdfBlocks.photoCircle(data.photo!, 96)),
        ),
        pw.SizedBox(height: 14),
      ] else
        pw.SizedBox(height: 6),

      pad(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(labels.contact, style: theme.sidebarHeading),
            pw.SizedBox(height: 6),
            ...PdfBlocks.contactLines(theme, info, sidebar: true),
          ],
        ),
      ),
      pw.SizedBox(height: 14),

      if (resume.visibleSkills.isNotEmpty) ...<pw.Widget>[
        pad(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(labels.skills, style: theme.sidebarHeading),
              pw.SizedBox(height: 6),
              PdfBlocks.skillBars(theme, resume.visibleSkills),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],

      if (resume.visibleLanguages.isNotEmpty) ...<pw.Widget>[
        pad(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(labels.languages, style: theme.sidebarHeading),
              pw.SizedBox(height: 6),
              PdfBlocks.languageList(
                theme,
                resume.visibleLanguages,
                sidebar: true,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],

      if (resume.visibleLinks.isNotEmpty)
        pad(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(labels.links, style: theme.sidebarHeading),
              pw.SizedBox(height: 6),
              PdfBlocks.linkList(theme, resume.visibleLinks, sidebar: true),
            ],
          ),
        ),
      pw.SizedBox(height: 10),
    ];
  }

  List<pw.Widget> _mainChildren(ResumeRenderData data) {
    final resume = data.resume;
    final theme = data.theme;
    final labels = theme.labels;
    final info = resume.personalInfo;

    return <pw.Widget>[
      pw.SizedBox(height: 6),
      pw.Text(info.fullName, style: theme.name),
      if (info.jobTitle.trim().isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 3),
        pw.Text(info.jobTitle.trim(), style: theme.jobTitle),
      ],
      pw.SizedBox(height: 10),
      pw.Container(height: 1.2, color: theme.accent, width: 54),
      pw.SizedBox(height: 16),

      if (resume.hasSummary) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.summary),
        PdfBlocks.paragraph(theme, resume.professionalSummary.trim()),
        PdfBlocks.gap(14),
      ],

      if (resume.visibleExperiences.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.experience),
        for (final (index, item) in resume.visibleExperiences.indexed)
          PdfBlocks.experienceEntry(
            theme,
            item,
            last: index == resume.visibleExperiences.length - 1,
          ),
        PdfBlocks.gap(14),
      ],

      if (resume.visibleEducations.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.education),
        for (final (index, item) in resume.visibleEducations.indexed)
          PdfBlocks.educationEntry(
            theme,
            item,
            last: index == resume.visibleEducations.length - 1,
          ),
        PdfBlocks.gap(14),
      ],

      if (resume.visibleProjects.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.projects),
        for (final (index, item) in resume.visibleProjects.indexed)
          PdfBlocks.projectEntry(
            theme,
            item,
            last: index == resume.visibleProjects.length - 1,
          ),
        PdfBlocks.gap(14),
      ],

      if (resume.visibleCertifications.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.certifications),
        for (final (index, item) in resume.visibleCertifications.indexed)
          PdfBlocks.certificationEntry(
            theme,
            item,
            last: index == resume.visibleCertifications.length - 1,
          ),
      ],
    ];
  }
}
