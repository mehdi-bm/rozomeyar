import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/education.dart';
import '../../../../domain/models/enums.dart';
import 'item_sheet_scaffold.dart';

Future<Education?> showEducationSheet(
  BuildContext context, {
  required ResumeLanguage language,
  Education? initial,
}) {
  return showItemSheet<Education>(
    context,
    builder: (sheetContext, controller) => _EducationForm(
      scrollController: controller,
      language: language,
      initial: initial,
    ),
  );
}

class _EducationForm extends StatefulWidget {
  const _EducationForm({
    required this.scrollController,
    required this.language,
    required this.initial,
  });

  final ScrollController scrollController;
  final ResumeLanguage language;
  final Education? initial;

  @override
  State<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<_EducationForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _degree;
  late final TextEditingController _fieldOfStudy;
  late final TextEditingController _institution;
  late final TextEditingController _city;
  late final TextEditingController _description;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _degree = TextEditingController(text: initial?.degree ?? '');
    _fieldOfStudy = TextEditingController(text: initial?.fieldOfStudy ?? '');
    _institution = TextEditingController(text: initial?.institution ?? '');
    _city = TextEditingController(text: initial?.city ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _startDate = initial?.startDate;
    _endDate = initial?.endDate;
    _isCurrent = initial?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _degree.dispose();
    _fieldOfStudy.dispose();
    _institution.dispose();
    _city.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final base = widget.initial ?? Education(id: newId());
    Navigator.of(context).pop(
      Education(
        id: base.id,
        degree: _degree.text.trim(),
        fieldOfStudy: _fieldOfStudy.text.trim(),
        institution: _institution.text.trim(),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        startDate: _startDate,
        endDate: _isCurrent ? null : _endDate,
        isCurrent: _isCurrent,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = widget.language.textDirection;

    return ItemSheetBody(
      title: widget.initial == null ? l10n.addEducation : l10n.editEducation,
      controller: widget.scrollController,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _degree,
          label: l10n.fieldDegree,
          autofocus: widget.initial == null,
          textDirection: content,
        ),
        AppTextField(
          controller: _fieldOfStudy,
          label: l10n.fieldFieldOfStudy,
          textDirection: content,
        ),
        AppTextField(
          controller: _institution,
          label: l10n.fieldInstitution,
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
      ],
    );
  }
}
