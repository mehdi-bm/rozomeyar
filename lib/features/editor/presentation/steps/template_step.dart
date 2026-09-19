import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/template_settings.dart';
import '../../../../pdf/templates/template_registry.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../widgets/editor_section.dart';
import '../widgets/template_thumbnail.dart';

String templateName(AppLocalizations l10n, TemplateId id) => switch (id) {
  TemplateId.classic => l10n.templateClassic,
  TemplateId.modern => l10n.templateModern,
  TemplateId.minimal => l10n.templateMinimal,
};

String templateDescription(AppLocalizations l10n, TemplateId id) =>
    switch (id) {
      TemplateId.classic => l10n.templateClassicDesc,
      TemplateId.modern => l10n.templateModernDesc,
      TemplateId.minimal => l10n.templateMinimalDesc,
    };

class TemplateStep extends StatelessWidget {
  const TemplateStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.templateSettings != current.resume.templateSettings ||
          previous.resume.language != current.resume.language,
      builder: (context, state) {
        final settings = state.resume.templateSettings;
        final cubit = context.read<ResumeEditorCubit>();

        void update(TemplateSettings next) {
          cubit.edit((resume) => resume.copyWith(templateSettings: next));
        }

        return EditorSection(
          title: l10n.stepTemplate,
          children: <Widget>[
            for (final template in TemplateRegistry.all)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _TemplateOption(
                  id: template.id,
                  selected: settings.templateId == template.id,
                  accent: settings.accent.color,
                  language: state.resume.language,
                  onTap: () =>
                      update(settings.copyWith(templateId: template.id)),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            TemplateCustomization(
              settings: settings,
              onChanged: update,
            ),
          ],
        );
      },
    );
  }
}

class _TemplateOption extends StatelessWidget {
  const _TemplateOption({
    required this.id,
    required this.selected,
    required this.accent,
    required this.language,
    required this.onTap,
  });

  final TemplateId id;
  final bool selected;
  final Color accent;
  final ResumeLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TemplateThumbnail(id: id, accent: accent, language: language),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      templateName(l10n, id),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      templateDescription(l10n, id),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accent colour, photo toggle and font size — shared by the editor step and
/// the preview screen's customization sheet.
class TemplateCustomization extends StatelessWidget {
  const TemplateCustomization({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final TemplateSettings settings;
  final ValueChanged<TemplateSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final supportsPhoto = TemplateRegistry.byId(
      settings.templateId,
    ).supportsPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.customizeTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.customizeAccent, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            for (final accent in ResumeAccents.all)
              _AccentSwatch(
                accent: accent,
                selected: settings.accentColorValue == accent.value,
                onTap: () =>
                    onChanged(settings.copyWith(accentColorValue: accent.value)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.customizeFontSize, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<FontScale>(
          segments: <ButtonSegment<FontScale>>[
            ButtonSegment<FontScale>(
              value: FontScale.small,
              label: Text(l10n.fontSizeSmall),
            ),
            ButtonSegment<FontScale>(
              value: FontScale.normal,
              label: Text(l10n.fontSizeNormal),
            ),
            ButtonSegment<FontScale>(
              value: FontScale.large,
              label: Text(l10n.fontSizeLarge),
            ),
          ],
          selected: <FontScale>{settings.fontScale},
          onSelectionChanged: (selection) =>
              onChanged(settings.copyWith(fontScale: selection.first)),
        ),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: supportsPhoto && settings.showProfilePhoto,
          title: Text(l10n.customizeShowPhoto),
          subtitle: supportsPhoto
              ? null
              : Text(l10n.customizeShowPhotoDisabled),
          onChanged: supportsPhoto
              ? (value) => onChanged(settings.copyWith(showProfilePhoto: value))
              : null,
        ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final ResumeAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.onSurface : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
