import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/resume.dart';

enum ResumeCardAction {
  edit,
  preview,
  toggleFavorite,
  translate,
  exportExcel,
  duplicate,
  rename,
  delete,
}

class ResumeCard extends StatelessWidget {
  const ResumeCard({
    super.key,
    required this.resume,
    required this.onOpen,
    required this.onAction,
  });

  final Resume resume;
  final VoidCallback onOpen;
  final ValueChanged<ResumeCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final accent = resume.templateSettings.accent.color;

    return Card(
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          resume.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.homeLastEdited(
                            AppDateFormat.uiDate(resume.updatedAt, localeCode),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: resume.isFavorite
                        ? l10n.favoriteRemove
                        : l10n.favoriteAdd,
                    onPressed: () =>
                        onAction(ResumeCardAction.toggleFavorite),
                    icon: Icon(
                      resume.isFavorite ? Icons.star : Icons.star_border,
                      color: resume.isFavorite
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  PopupMenuButton<ResumeCardAction>(
                    onSelected: onAction,
                    itemBuilder: (context) => <PopupMenuEntry<ResumeCardAction>>[
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.edit,
                        child: _MenuRow(
                          icon: Icons.edit_outlined,
                          label: l10n.commonEdit,
                        ),
                      ),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.preview,
                        child: _MenuRow(
                          icon: Icons.visibility_outlined,
                          label: l10n.commonPreview,
                        ),
                      ),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.translate,
                        child: _MenuRow(
                          icon: Icons.translate,
                          label: l10n.translateTitle,
                        ),
                      ),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.exportExcel,
                        child: _MenuRow(
                          icon: Icons.table_view_outlined,
                          label: l10n.backupExport,
                        ),
                      ),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.rename,
                        child: _MenuRow(
                          icon: Icons.drive_file_rename_outline,
                          label: l10n.homeRename,
                        ),
                      ),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.duplicate,
                        child: _MenuRow(
                          icon: Icons.copy_all_outlined,
                          label: l10n.commonDuplicate,
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<ResumeCardAction>(
                        value: ResumeCardAction.delete,
                        child: _MenuRow(
                          icon: Icons.delete_outline,
                          label: l10n.commonDelete,
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  _Tag(
                    icon: Icons.translate,
                    label: resume.language == ResumeLanguage.persian
                        ? l10n.resumeLanguagePersian
                        : l10n.resumeLanguageEnglish,
                  ),
                  _Tag(
                    icon: Icons.dashboard_customize_outlined,
                    label: _templateLabel(l10n, resume.templateSettings.templateId),
                  ),
                  if (resume.isSample)
                    _Tag(
                      icon: Icons.auto_awesome_outlined,
                      label: l10n.homeSampleBadge,
                      highlighted: true,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: resume.completeness,
                  minHeight: 4,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  // The theme's generous button padding does not leave room for
                  // «پیش‌نمایش» at half the card width, so these two override it
                  // and keep their labels on a single line.
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAction(ResumeCardAction.preview),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: Text(
                        l10n.commonPreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onAction(ResumeCardAction.edit),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        l10n.commonEdit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _templateLabel(AppLocalizations l10n, TemplateId id) =>
      switch (id) {
        TemplateId.classic => l10n.templateClassic,
        TemplateId.modern => l10n.templateModern,
        TemplateId.minimal => l10n.templateMinimal,
      };
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = highlighted
        ? scheme.tertiaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = highlighted
        ? scheme.onTertiaryContainer
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
