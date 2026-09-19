import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/enums.dart';

class CreateResumeResult {
  const CreateResumeResult({required this.title, required this.language});

  final String title;
  final ResumeLanguage language;
}

Future<CreateResumeResult?> showCreateResumeSheet(
  BuildContext context, {
  required ResumeLanguage defaultLanguage,
}) {
  return showModalBottomSheet<CreateResumeResult>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _CreateResumeSheet(defaultLanguage: defaultLanguage),
  );
}

class _CreateResumeSheet extends StatefulWidget {
  const _CreateResumeSheet({required this.defaultLanguage});

  final ResumeLanguage defaultLanguage;

  @override
  State<_CreateResumeSheet> createState() => _CreateResumeSheetState();
}

class _CreateResumeSheetState extends State<_CreateResumeSheet> {
  late final TextEditingController _titleController;
  late ResumeLanguage _language = widget.defaultLanguage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    Navigator.of(context).pop(
      CreateResumeResult(
        title: title.isEmpty ? l10n.homeNewResumeTitle : title,
        language: _language,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.homeCreateSheetTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _titleController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.homeCreateSheetName,
              hintText: l10n.homeCreateSheetNameHint,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.homeCreateSheetLanguage,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ResumeLanguage>(
            segments: <ButtonSegment<ResumeLanguage>>[
              ButtonSegment<ResumeLanguage>(
                value: ResumeLanguage.persian,
                label: Text(l10n.resumeLanguagePersian),
              ),
              ButtonSegment<ResumeLanguage>(
                value: ResumeLanguage.english,
                label: Text(l10n.resumeLanguageEnglish),
              ),
            ],
            selected: <ResumeLanguage>{_language},
            onSelectionChanged: (selection) =>
                setState(() => _language = selection.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(l10n.homeCreateCta),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple single-field rename dialog, returns the new title or null.
Future<String?> showRenameResumeDialog(
  BuildContext context, {
  required String initialTitle,
}) {
  final controller = TextEditingController(text: initialTitle);
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;
      return AlertDialog(
        title: Text(l10n.homeRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) =>
              Navigator.of(dialogContext).pop(value.trim()),
          decoration: InputDecoration(labelText: l10n.homeCreateSheetName),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}
