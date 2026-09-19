import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/skill.dart';
import 'item_sheet_scaffold.dart';

String skillLevelLabel(AppLocalizations l10n, SkillLevel level) =>
    switch (level) {
      SkillLevel.beginner => l10n.skillLevelBeginner,
      SkillLevel.intermediate => l10n.skillLevelIntermediate,
      SkillLevel.advanced => l10n.skillLevelAdvanced,
      SkillLevel.expert => l10n.skillLevelExpert,
    };

Future<Skill?> showSkillSheet(
  BuildContext context, {
  required ResumeLanguage language,
  Skill? initial,
}) {
  return showCompactItemSheet<Skill>(
    context,
    builder: (sheetContext) =>
        _SkillForm(initial: initial, language: language),
  );
}

class _SkillForm extends StatefulWidget {
  const _SkillForm({required this.initial, required this.language});

  final Skill? initial;
  final ResumeLanguage language;

  @override
  State<_SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends State<_SkillForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  SkillLevel? _level;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _level = widget.initial?.level;
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
      Skill(id: widget.initial?.id ?? newId(), name: name, level: _level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CompactItemSheetBody(
      title: widget.initial == null ? l10n.addSkill : l10n.editSkill,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _name,
          label: l10n.fieldSkillName,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.done,
          textDirection: widget.language.textDirection,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${l10n.fieldSkillLevel} (${l10n.commonOptional})',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final level in SkillLevel.values)
              ChoiceChip(
                label: Text(skillLevelLabel(l10n, level)),
                selected: _level == level,
                onSelected: (selected) =>
                    setState(() => _level = selected ? level : null),
              ),
          ],
        ),
      ],
    );
  }
}
