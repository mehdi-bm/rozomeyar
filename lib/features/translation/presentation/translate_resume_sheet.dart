import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/resume.dart';
import '../../../domain/services/resume_translator.dart';
import '../../../domain/services/translation_service.dart';

/// Result of a successful translation: the freshly created resume.
Future<Resume?> showTranslateResumeSheet(
  BuildContext context, {
  required Resume resume,
  required TranslationService service,
}) {
  return showModalBottomSheet<Resume>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    builder: (sheetContext) => _TranslateSheet(
      resume: resume,
      service: service,
    ),
  );
}

enum _Stage { idle, checking, downloading, translating }

class _TranslateSheet extends StatefulWidget {
  const _TranslateSheet({required this.resume, required this.service});

  final Resume resume;
  final TranslationService service;

  @override
  State<_TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends State<_TranslateSheet> {
  late ResumeLanguage _target;
  _Stage _stage = _Stage.idle;
  bool? _modelsReady;
  int _done = 0;
  int _total = 0;

  List<ResumeLanguage> get _targets => ResumeLanguage.values
      .where((language) => language != widget.resume.language)
      .toList();

  bool get _busy => _stage != _Stage.idle;

  @override
  void initState() {
    super.initState();
    _target = _targets.first;
    _refreshModelState();
  }

  /// ML Kit needs the model for *both* ends of the pair, so both are checked.
  Future<void> _refreshModelState() async {
    setState(() {
      _stage = _Stage.checking;
      _modelsReady = null;
    });
    try {
      final source = await widget.service.isModelReady(widget.resume.language);
      final target = await widget.service.isModelReady(_target);
      if (!mounted) return;
      setState(() {
        _modelsReady = source && target;
        _stage = _Stage.idle;
      });
    } on AppFailure {
      if (!mounted) return;
      setState(() {
        _modelsReady = false;
        _stage = _Stage.idle;
      });
    }
  }

  Future<void> _start() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    try {
      if (_modelsReady != true) {
        setState(() => _stage = _Stage.downloading);
        for (final language in <ResumeLanguage>[
          widget.resume.language,
          _target,
        ]) {
          final ok = await widget.service.downloadModel(language);
          if (!ok) throw AppFailure(AppFailureKind.translationModelDownload);
        }
      }

      if (!mounted) return;
      setState(() {
        _stage = _Stage.translating;
        _done = 0;
        _total = 0;
      });

      final translator = ResumeTranslator(widget.service);
      final translated = await translator.translate(
        widget.resume,
        target: _target,
        titleBuilder: (original) => l10n.translateNewTitle(
          original,
          resumeLanguageLabel(l10n, _target),
        ),
        onProgress: (done, total) {
          if (!mounted) return;
          setState(() {
            _done = done;
            _total = total;
          });
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(translated);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() => _stage = _Stage.idle);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(failure.kind.message(l10n))),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _stage = _Stage.idle);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.errorTranslationFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.translateTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xl),

            Text(l10n.translateTo, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ResumeLanguage>(
              segments: <ButtonSegment<ResumeLanguage>>[
                for (final language in _targets)
                  ButtonSegment<ResumeLanguage>(
                    value: language,
                    label: Text(resumeLanguageLabel(l10n, language)),
                  ),
              ],
              selected: <ResumeLanguage>{_target},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() => _target = selection.first);
                      _refreshModelState();
                    },
            ),
            const SizedBox(height: AppSpacing.lg),

            _Note(
              icon: Icons.phonelink_lock_outlined,
              text: l10n.translateOfflineNote,
              color: scheme.primary,
            ),
            _Note(
              icon: _modelsReady == true
                  ? Icons.offline_pin_outlined
                  : Icons.cloud_download_outlined,
              text: _modelsReady == true
                  ? l10n.translateModelReady
                  : l10n.translateModelNeeded,
              color: scheme.onSurfaceVariant,
            ),
            _Note(
              icon: Icons.info_outline,
              text: l10n.translateWarning,
              color: context.semanticColors.warning,
            ),
            if (_target == ResumeLanguage.arabic)
              _Note(
                icon: Icons.translate_outlined,
                text: l10n.translateArabicWarning,
                color: context.semanticColors.warning,
              ),

            const SizedBox(height: AppSpacing.lg),
            if (_busy) _Progress(stage: _stage, done: _done, total: _total),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _busy ? null : _start,
              icon: const Icon(Icons.translate),
              label: Text(l10n.translateAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.stage, required this.done, required this.total});

  final _Stage stage;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final label = switch (stage) {
      _Stage.downloading => l10n.translateDownloading,
      _Stage.translating => total == 0
          ? l10n.translateWorking
          : '${l10n.translateWorking} ${l10n.translateProgress(done, total)}',
      _ => l10n.translateWorking,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            // Model download offers no progress signal, so it stays
            // indeterminate; the per-field pass has a real ratio.
            value: stage == _Stage.translating && total > 0
                ? done / total
                : null,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
