import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/enums.dart';
import '../pdf_theme.dart';
import 'pdf_blocks.dart';
import 'resume_template.dart';

/// Formal single-column layout for corporate applications: centred header,
/// rule under the name, restrained use of the accent colour.
class ClassicTemplate extends ResumeTemplate {
  const ClassicTemplate();

  @override
  TemplateId get id => TemplateId.classic;

  @override
  bool get supportsPhoto => false;

  @override
  pw.EdgeInsets margin(ResumePdfTheme theme) =>
      const pw.EdgeInsets.fromLTRB(40, 38, 40, 38);

  @override
  List<pw.Widget> build(ResumeRenderData data) {
    final resume = data.resume;
    final theme = data.theme;
    final labels = theme.labels;
    final info = resume.personalInfo;

    return <pw.Widget>[
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Text(info.fullName, style: theme.name),
          if (info.jobTitle.trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 3),
            pw.Text(info.jobTitle.trim(), style: theme.jobTitle),
          ],
          pw.SizedBox(height: 8),
          PdfBlocks.contactInline(theme, info),
          pw.SizedBox(height: 10),
          pw.Container(height: 1.2, color: theme.accent),
        ],
      ),
      PdfBlocks.gap(16),

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

      if (resume.visibleSkills.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.skills),
        PdfBlocks.skillChips(theme, resume.visibleSkills),
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
        PdfBlocks.gap(14),
      ],

      if (resume.visibleLanguages.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.languages),
        PdfBlocks.languageList(theme, resume.visibleLanguages),
        PdfBlocks.gap(14),
      ],

      if (resume.visibleLinks.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.sectionHeading(theme, labels.links),
        PdfBlocks.linkList(theme, resume.visibleLinks),
      ],
    ];
  }
}
