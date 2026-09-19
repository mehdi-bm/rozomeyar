import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/resume_language_item.dart';
import 'item_sheet_scaffold.dart';

String languageLevelLabel(AppLocalizations l10n, LanguageLevel level) =>
    switch (level) {
      LanguageLevel.basic => l10n.langLevelBasic,
      LanguageLevel.intermediate => l10n.langLevelIntermediate,
      LanguageLevel.professional => l10n.langLevelProfessional,
      LanguageLevel.fluent => l10n.langLevelFluent,
      LanguageLevel.native => l10n.langLevelNative,
    };

Future<ResumeLanguageItem?> showLanguageSheet(
  BuildContext context, {
  required ResumeLanguage language,
  ResumeLanguageItem? initial,
}) {
  return showCompactItemSheet<ResumeLanguageItem>(
    context,
    builder: (sheetContext) =>
        _LanguageForm(initial: initial, language: language),
  );
}

class _LanguageForm extends StatefulWidget {
  const _LanguageForm({required this.initial, required this.language});

  final ResumeLanguageItem? initial;
  final ResumeLanguage language;

  @override
  State<_LanguageForm> createState() => _LanguageFormState();
}

class _LanguageFormState extends State<_LanguageForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late LanguageLevel _level;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _level = widget.initial?.level ?? LanguageLevel.intermediate;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      ResumeLanguageItem(
        id: widget.initial?.id ?? newId(),
        name: name,
        level: _level,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CompactItemSheetBody(
      title: widget.initial == null ? l10n.addLanguage : l10n.editLanguage,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _name,
          label: l10n.fieldLanguageName,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.done,
          textDirection: widget.language.textDirection,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.fieldLanguageLevel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final level in LanguageLevel.values)
              ChoiceChip(
                label: Text(languageLevelLabel(l10n, level)),
                selected: _level == level,
                onSelected: (selected) {
                  if (selected) setState(() => _level = level);
                },
              ),
          ],
        ),
      ],
    );
  }
}
