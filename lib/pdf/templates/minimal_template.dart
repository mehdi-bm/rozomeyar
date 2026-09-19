import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/enums.dart';
import '../../domain/models/skill.dart';
import '../pdf_theme.dart';
import 'pdf_blocks.dart';
import 'resume_template.dart';

/// Typography-led layout: generous margins, a left-aligned header, hairline
/// rules instead of coloured blocks, and skills as a plain readable list.
class MinimalTemplate extends ResumeTemplate {
  const MinimalTemplate();

  @override
  TemplateId get id => TemplateId.minimal;

  @override
  bool get supportsPhoto => false;

  @override
  pw.EdgeInsets margin(ResumePdfTheme theme) =>
      const pw.EdgeInsets.fromLTRB(58, 54, 58, 54);

  @override
  List<pw.Widget> build(ResumeRenderData data) {
    final resume = data.resume;
    final theme = data.theme;
    final labels = theme.labels;
    final info = resume.personalInfo;

    return <pw.Widget>[
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            info.fullName,
            style: theme.name.copyWith(
              fontSize: theme.size(24),
              letterSpacing: theme.isRtl ? 0 : 0.5,
            ),
          ),
          if (info.jobTitle.trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 4),
            pw.Text(info.jobTitle.trim(), style: theme.jobTitle),
          ],
          pw.SizedBox(height: 12),
          PdfBlocks.contactInline(theme, info),
        ],
      ),
      PdfBlocks.gap(26),

      if (resume.hasSummary) ...<pw.Widget>[
        PdfBlocks.paragraph(theme, resume.professionalSummary.trim()),
        PdfBlocks.gap(24),
      ],

      if (resume.visibleExperiences.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.experience),
        for (final (index, item) in resume.visibleExperiences.indexed)
          PdfBlocks.experienceEntry(
            theme,
            item,
            last: index == resume.visibleExperiences.length - 1,
          ),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleEducations.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.education),
        for (final (index, item) in resume.visibleEducations.indexed)
          PdfBlocks.educationEntry(
            theme,
            item,
            last: index == resume.visibleEducations.length - 1,
          ),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleProjects.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.projects),
        for (final (index, item) in resume.visibleProjects.indexed)
          PdfBlocks.projectEntry(
            theme,
            item,
            last: index == resume.visibleProjects.length - 1,
          ),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleSkills.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.skills),
        pw.Text(_skillLine(theme, resume.visibleSkills), style: theme.body),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleCertifications.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.certifications),
        for (final (index, item) in resume.visibleCertifications.indexed)
          PdfBlocks.certificationEntry(
            theme,
            item,
            last: index == resume.visibleCertifications.length - 1,
          ),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleLanguages.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.languages),
        PdfBlocks.languageList(theme, resume.visibleLanguages),
        PdfBlocks.gap(20),
      ],

      if (resume.visibleLinks.isNotEmpty) ...<pw.Widget>[
        PdfBlocks.ruledHeading(theme, labels.links),
        PdfBlocks.linkList(theme, resume.visibleLinks),
      ],
    ];
  }

  /// Minimal deliberately avoids chips and bars — skills read as one sentence.
  static String _skillLine(ResumePdfTheme theme, List<Skill> skills) {
    final showLevels = theme.settings.showSkillLevels;
    return skills
        .map((skill) {
          final name = skill.name.trim();
          if (!showLevels || skill.level == null) return name;
          return '$name (${theme.labels.skillLevels[skill.level]})';
        })
        .join(theme.labels.listSeparator);
  }
}
