import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/resume.dart';
import '../../../domain/models/template_settings.dart';
import '../../../pdf/resume_pdf_service.dart';
import '../../../pdf/templates/template_registry.dart';
import '../../editor/cubit/resume_editor_cubit.dart';
import '../../editor/presentation/steps/template_step.dart';
import '../../editor/presentation/widgets/template_thumbnail.dart';

/// Shows the *actual* generated PDF rather than a widget approximation, so what
/// the user scrolls through is exactly the file they export.
class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  static const ResumePdfService _service = ResumePdfService();

  bool _busy = false;

  Future<Uint8List> _build(Resume resume) => _service.build(resume);

  Future<void> _run(
    Future<void> Function(Resume resume, Uint8List bytes) action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    final cubit = context.read<ResumeEditorCubit>();
    try {
      await cubit.save();
      final resume = cubit.state.resume;
      final bytes = await _service.build(resume);
      await action(resume, bytes);
    } on AppFailure catch (failure) {
      if (mounted) showFailureSnackBar(context, failure.kind);
    } catch (_) {
      if (mounted) showFailureSnackBar(context, AppFailureKind.pdfGeneration);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    await _run((resume, bytes) async {
      final file = await _service.saveToFile(resume, bytes);
      if (!mounted) return;
      showAppSnackBar(context, l10n.previewSavedAt(file.path));
    });
  }

  Future<void> _share() =>
      _run((resume, bytes) => _service.share(resume, bytes));

  Future<void> _openCustomization() async {
    final cubit = context.read<ResumeEditorCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
              bloc: cubit,
              buildWhen: (previous, current) =>
                  previous.resume.templateSettings !=
                  current.resume.templateSettings,
              builder: (context, state) => ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: <Widget>[
                  _TemplatePicker(
                    settings: state.resume.templateSettings,
                    language: state.resume.language,
                    onChanged: (next) => cubit.edit(
                      (resume) => resume.copyWith(templateSettings: next),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TemplateCustomization(
                    settings: state.resume.templateSettings,
                    onChanged: (next) => cubit.edit(
                      (resume) => resume.copyWith(templateSettings: next),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
    // Persist whatever was changed in the sheet before the preview re-renders.
    await cubit.save();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      builder: (context, state) {
        final resume = state.resume;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.previewTitle),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.customizeTitle,
                onPressed: _busy ? null : _openCustomization,
                icon: const Icon(Icons.tune),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: Stack(
            children: <Widget>[
              PdfPreview(
                // Regenerates whenever template settings or content change.
                key: ValueKey<int>(
                  Object.hash(resume.templateSettings, resume.updatedAt),
                ),
                build: (format) => _build(resume),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: false,
                useActions: true,
                shouldRepaint: true,
                pdfFileName: _service.fileName(resume),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(),
                ),
                onError: (context, error) => Center(
                  child: Padding(
                    padding: AppSpacing.pagePadding,
                    child: Text(
                      l10n.errorPdfGeneration,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_busy)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.scrim.withValues(alpha: 0.35),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.previewGenerating,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _export,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(l10n.previewExport),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.previewShare),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact template row used inside the preview's customization sheet.
class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({
    required this.settings,
    required this.language,
    required this.onChanged,
  });

  final TemplateSettings settings;
  final ResumeLanguage language;
  final ValueChanged<TemplateSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.previewChangeTemplate, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            for (final template in TemplateRegistry.all)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _TemplateChoice(
                    id: template.id,
                    selected: settings.templateId == template.id,
                    accent: settings.accent.color,
                    language: language,
                    onTap: () => onChanged(
                      settings.copyWith(templateId: template.id),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TemplateChoice extends StatelessWidget {
  const _TemplateChoice({
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

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fieldRadius,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: TemplateThumbnail(
                  id: id,
                  accent: accent,
                  language: language,
                  width: 58,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              templateName(context.l10n, id),
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
