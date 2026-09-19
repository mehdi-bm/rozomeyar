import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/date_format.dart';
import '../../domain/models/certification.dart';
import '../../domain/models/education.dart';
import '../../domain/models/experience.dart';
import '../../domain/models/personal_info.dart';
import '../../domain/models/project.dart';
import '../../domain/models/resume_language_item.dart';
import '../../domain/models/resume_link.dart';
import '../../domain/models/skill.dart';
import '../pdf_theme.dart';

/// Reusable PDF building blocks shared by all three templates, so a change to
/// how (say) an experience entry reads applies everywhere at once.
abstract final class PdfBlocks {
  static pw.Widget gap(double height) => pw.SizedBox(height: height);

  /// Section heading with a short accent rule underneath.
  static pw.Widget sectionHeading(ResumePdfTheme theme, String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(text, style: theme.sectionHeading),
        pw.SizedBox(height: 3),
        pw.Container(width: 34, height: 1.6, color: theme.accent),
        pw.SizedBox(height: 8),
      ],
    );
  }

  /// Heading style used by Minimal: a full-width hairline instead of a stub.
  static pw.Widget ruledHeading(ResumePdfTheme theme, String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(text, style: theme.sectionHeading),
        pw.SizedBox(height: 4),
        pw.Container(height: 0.8, color: ResumePdfTheme.hairline),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget paragraph(ResumePdfTheme theme, String text) =>
      pw.Text(text, style: theme.body, textAlign: pw.TextAlign.justify);

  static pw.Widget bullets(ResumePdfTheme theme, List<String> lines) {
    if (lines.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (final line in lines)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3.5),
                  child: pw.Container(
                    width: 3,
                    height: 3,
                    decoration: pw.BoxDecoration(
                      color: theme.accent,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(child: pw.Text(line, style: theme.body)),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Entry blocks
  // ---------------------------------------------------------------------------

  static pw.Widget experienceEntry(
    ResumePdfTheme theme,
    Experience item, {
    bool last = false,
  }) {
    final period = AppDateFormat.range(
      start: item.startDate,
      end: item.endDate,
      isCurrent: item.isCurrent,
      language: theme.language,
      presentLabel: theme.labels.present,
    );
    final subtitleParts = <String>[
      if (item.company.trim().isNotEmpty) item.company.trim(),
      if ((item.city ?? '').trim().isNotEmpty) item.city!.trim(),
    ];

    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: last ? 0 : 11),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _titleAndPeriod(theme, item.jobTitle, period),
          if (subtitleParts.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            pw.Text(
              subtitleParts.join(theme.labels.listSeparator),
              style: theme.itemSubtitle,
            ),
          ],
          if ((item.description ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 4),
            paragraph(theme, item.description!.trim()),
          ],
          if (item.achievementLines.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 4),
            bullets(theme, item.achievementLines),
          ],
        ],
      ),
    );
  }

  static pw.Widget educationEntry(
    ResumePdfTheme theme,
    Education item, {
    bool last = false,
  }) {
    final period = AppDateFormat.range(
      start: item.startDate,
      end: item.endDate,
      isCurrent: item.isCurrent,
      language: theme.language,
      presentLabel: theme.labels.present,
    );
    final subtitleParts = <String>[
      if (item.institution.trim().isNotEmpty) item.institution.trim(),
      if ((item.city ?? '').trim().isNotEmpty) item.city!.trim(),
    ];

    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: last ? 0 : 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _titleAndPeriod(theme, item.headline, period),
          if (subtitleParts.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            pw.Text(
              subtitleParts.join(theme.labels.listSeparator),
              style: theme.itemSubtitle,
            ),
          ],
          if ((item.description ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 4),
            paragraph(theme, item.description!.trim()),
          ],
        ],
      ),
    );
  }

  static pw.Widget projectEntry(
    ResumePdfTheme theme,
    Project item, {
    bool last = false,
  }) {
    final period = AppDateFormat.range(
      start: item.startDate,
      end: item.endDate,
      isCurrent: false,
      language: theme.language,
      presentLabel: theme.labels.present,
    );

    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: last ? 0 : 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _titleAndPeriod(theme, item.name, period),
          if ((item.role ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            pw.Text(item.role!.trim(), style: theme.itemSubtitle),
          ],
          if ((item.description ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 4),
            paragraph(theme, item.description!.trim()),
          ],
          if ((item.technologies ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 3),
            pw.Text(
              '${theme.labels.technologies}: ${item.technologies!.trim()}',
              style: theme.meta,
            ),
          ],
          if ((item.url ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            _ltrText(theme, item.url!.trim(), theme.meta),
          ],
        ],
      ),
    );
  }

  static pw.Widget certificationEntry(
    ResumePdfTheme theme,
    Certification item, {
    bool last = false,
  }) {
    final date = item.issueDate == null
        ? ''
        : AppDateFormat.monthYear(item.issueDate!, theme.language);

    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: last ? 0 : 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _titleAndPeriod(theme, item.name, date),
          if ((item.organization ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            pw.Text(item.organization!.trim(), style: theme.itemSubtitle),
          ],
          if ((item.description ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 3),
            paragraph(theme, item.description!.trim()),
          ],
          if ((item.credentialUrl ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            _ltrText(theme, item.credentialUrl!.trim(), theme.meta),
          ],
        ],
      ),
    );
  }

  /// Skills as a wrapped row of pills — compact and reads well in both scripts.
  static pw.Widget skillChips(ResumePdfTheme theme, List<Skill> skills) {
    final showLevels = theme.settings.showSkillLevels;
    return pw.Wrap(
      spacing: 5,
      runSpacing: 5,
      children: <pw.Widget>[
        for (final skill in skills)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 3.5,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColorTint.tint(theme.accent),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              showLevels && skill.level != null
                  ? '${skill.name.trim()} · ${theme.labels.skillLevels[skill.level]}'
                  : skill.name.trim(),
              style: theme.body.copyWith(fontSize: theme.size(8.8)),
            ),
          ),
      ],
    );
  }

  /// Skills as name + proficiency bar, used by the Modern sidebar.
  static pw.Widget skillBars(ResumePdfTheme theme, List<Skill> skills) {
    final showLevels = theme.settings.showSkillLevels;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (final skill in skills)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(skill.name.trim(), style: theme.sidebarBody),
                if (showLevels && skill.level != null) ...<pw.Widget>[
                  pw.SizedBox(height: 2.5),
                  _levelBar(theme, skill.level!.rank, 4),
                ],
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget languageList(
    ResumePdfTheme theme,
    List<ResumeLanguageItem> languages, {
    bool sidebar = false,
  }) {
    final style = sidebar ? theme.sidebarBody : theme.body;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (final language in languages)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Text(language.name.trim(), style: style),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  theme.labels.languageLevels[language.level] ?? '',
                  style: theme.meta,
                ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget linkList(
    ResumePdfTheme theme,
    List<ResumeLink> links, {
    bool sidebar = false,
  }) {
    final style = sidebar ? theme.sidebarBody : theme.contact;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (final link in links)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(link.title.trim(), style: style),
                pw.UrlLink(
                  destination: link.url.trim(),
                  child: _ltrText(theme, link.url.trim(), theme.meta),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Contact details, one per line. Emails, phone numbers and URLs are forced
  /// LTR so they never get reversed inside a Persian document.
  static List<pw.Widget> contactLines(
    ResumePdfTheme theme,
    PersonalInfo info, {
    bool sidebar = false,
  }) {
    final style = sidebar ? theme.sidebarBody : theme.contact;
    final labels = theme.labels;
    final widgets = <pw.Widget>[];

    void add(pw.Widget child) {
      widgets.add(
        pw.Padding(padding: const pw.EdgeInsets.only(bottom: 3), child: child),
      );
    }

    if ((info.mobile ?? '').trim().isNotEmpty) {
      add(_ltrText(theme, info.mobile!.trim(), style));
    }
    if ((info.email ?? '').trim().isNotEmpty) {
      add(_ltrText(theme, info.email!.trim(), style));
    }
    final location = info.location(labels.listSeparator);
    if (location != null) {
      add(pw.Text(location, style: style));
    }
    if (info.visibility.showAddress && (info.address ?? '').trim().isNotEmpty) {
      add(pw.Text('${labels.address}: ${info.address!.trim()}', style: style));
    }
    if (info.visibility.showDateOfBirth && info.dateOfBirth != null) {
      add(
        pw.Text(
          '${labels.dateOfBirth}: '
          '${AppDateFormat.fullDate(info.dateOfBirth!, theme.language)}',
          style: style,
        ),
      );
    }
    if (info.visibility.showMaritalStatus && info.maritalStatus != null) {
      add(
        pw.Text(
          '${labels.maritalStatus}: '
          '${labels.maritalStatusLabel(info.maritalStatus!)}',
          style: style,
        ),
      );
    }
    return widgets;
  }

  /// Contact details laid out on one wrapped line, used by Classic/Minimal
  /// headers.
  static pw.Widget contactInline(ResumePdfTheme theme, PersonalInfo info) {
    final parts = <pw.Widget>[];
    final labels = theme.labels;

    void add(pw.Widget child) => parts.add(child);

    if ((info.mobile ?? '').trim().isNotEmpty) {
      add(_ltrText(theme, info.mobile!.trim(), theme.contact));
    }
    if ((info.email ?? '').trim().isNotEmpty) {
      add(_ltrText(theme, info.email!.trim(), theme.contact));
    }
    final location = info.location(labels.listSeparator);
    if (location != null) add(pw.Text(location, style: theme.contact));
    if (info.visibility.showAddress && (info.address ?? '').trim().isNotEmpty) {
      add(pw.Text(info.address!.trim(), style: theme.contact));
    }
    if (info.visibility.showDateOfBirth && info.dateOfBirth != null) {
      add(
        pw.Text(
          '${labels.dateOfBirth}: '
          '${AppDateFormat.fullDate(info.dateOfBirth!, theme.language)}',
          style: theme.contact,
        ),
      );
    }
    if (info.visibility.showMaritalStatus && info.maritalStatus != null) {
      add(
        pw.Text(
          '${labels.maritalStatus}: '
          '${labels.maritalStatusLabel(info.maritalStatus!)}',
          style: theme.contact,
        ),
      );
    }

    if (parts.isEmpty) return pw.SizedBox();

    final separated = <pw.Widget>[];
    for (var i = 0; i < parts.length; i++) {
      separated.add(parts[i]);
      if (i != parts.length - 1) {
        separated.add(
          pw.Text('  •  ', style: theme.meta),
        );
      }
    }
    return pw.Wrap(
      crossAxisAlignment: pw.WrapCrossAlignment.center,
      children: separated,
    );
  }

  static pw.Widget photoCircle(pw.ImageProvider image, double size) {
    return pw.ClipOval(
      child: pw.SizedBox(
        width: size,
        height: size,
        child: pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Segmented proficiency bar: [filled] of [total] segments in the accent
  /// colour. Segments rather than a continuous bar so the level is still
  /// countable in a black-and-white printout.
  static pw.Widget _levelBar(ResumePdfTheme theme, int filled, int total) {
    return pw.Row(
      children: <pw.Widget>[
        for (var i = 0; i < total; i++)
          pw.Expanded(
            child: pw.Container(
              height: 3,
              margin: pw.EdgeInsets.only(right: i == total - 1 ? 0 : 2),
              decoration: pw.BoxDecoration(
                color: i < filled
                    ? theme.accent
                    : PdfColorTint.tint(theme.accent, 0.75),
                borderRadius: pw.BorderRadius.circular(1.5),
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _titleAndPeriod(
    ResumePdfTheme theme,
    String title,
    String period,
  ) {
    if (period.isEmpty) {
      return pw.Text(title.trim(), style: theme.itemTitle);
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Expanded(child: pw.Text(title.trim(), style: theme.itemTitle)),
        pw.SizedBox(width: 8),
        pw.Text(period, style: theme.meta),
      ],
    );
  }

  /// Wraps Latin-only content (emails, URLs, phone numbers) in an LTR
  /// directionality island so RTL reordering leaves it alone.
  static pw.Widget _ltrText(
    ResumePdfTheme theme,
    String text,
    pw.TextStyle style,
  ) {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Text(text, style: style),
    );
  }
}

abstract final class PdfColorTint {
  /// Mixes the accent towards white so chips stay legible — and still readable
  /// when the resume is printed in greyscale.
  static PdfColor tint(PdfColor color, [double amount = 0.88]) {
    double mix(double channel) => channel + (1 - channel) * amount;
    return PdfColor(mix(color.red), mix(color.green), mix(color.blue));
  }
}
