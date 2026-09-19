import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/experience.dart';
import 'item_sheet_scaffold.dart';

Future<Experience?> showExperienceSheet(
  BuildContext context, {
  required ResumeLanguage language,
  Experience? initial,
}) {
  return showItemSheet<Experience>(
    context,
    builder: (sheetContext, controller) => _ExperienceForm(
      scrollController: controller,
      language: language,
      initial: initial,
    ),
  );
}

class _ExperienceForm extends StatefulWidget {
  const _ExperienceForm({
    required this.scrollController,
    required this.language,
    required this.initial,
  });

  final ScrollController scrollController;
  final ResumeLanguage language;
  final Experience? initial;

  @override
  State<_ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<_ExperienceForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _jobTitle;
  late final TextEditingController _company;
  late final TextEditingController _city;
  late final TextEditingController _description;
  late final TextEditingController _achievements;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _jobTitle = TextEditingController(text: initial?.jobTitle ?? '');
    _company = TextEditingController(text: initial?.company ?? '');
    _city = TextEditingController(text: initial?.city ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _achievements = TextEditingController(text: initial?.achievements ?? '');
    _startDate = initial?.startDate;
    _endDate = initial?.endDate;
    _isCurrent = initial?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _jobTitle.dispose();
    _company.dispose();
    _city.dispose();
    _description.dispose();
    _achievements.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final base = widget.initial ?? Experience(id: newId());
    Navigator.of(context).pop(
      Experience(
        id: base.id,
        jobTitle: _jobTitle.text.trim(),
        company: _company.text.trim(),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        achievements: _achievements.text.trim().isEmpty
            ? null
            : _achievements.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = widget.language.textDirection;

    return ItemSheetBody(
      title: widget.initial == null ? l10n.addExperience : l10n.editExperience,
      controller: widget.scrollController,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _jobTitle,
          label: l10n.fieldJobTitle,
          hint: l10n.fieldJobTitleHint,
          autofocus: widget.initial == null,
          textDirection: content,
        ),
        AppTextField(
          controller: _company,
          label: l10n.fieldCompany,
          textDirection: content,
        ),
        AppTextField(
          controller: _city,
          label: l10n.fieldCity,
          textDirection: content,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: DateField(
                label: l10n.fieldStartDate,
                value: _startDate,
                language: widget.language,
                onChanged: (value) => setState(() => _startDate = value),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DateField(
                label: l10n.fieldEndDate,
                value: _isCurrent ? null : _endDate,
                language: widget.language,
                enabled: !_isCurrent,
                placeholder: _isCurrent ? l10n.dateNow : null,
                onChanged: (value) => setState(() => _endDate = value),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isCurrent,
          title: Text(l10n.fieldCurrentlyWorking),
          onChanged: (value) => setState(() => _isCurrent = value),
        ),
        AppTextField(
          controller: _description,
          label: l10n.fieldDescription,
          maxLines: 4,
          minLines: 3,
          textDirection: content,
        ),
        AppTextField(
          controller: _achievements,
          label: l10n.fieldAchievements,
          helper: l10n.fieldAchievementsHint,
          maxLines: 5,
          minLines: 3,
          textDirection: content,
        ),
      ],
    );
  }
}
