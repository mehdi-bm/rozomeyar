import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/project.dart';
import '../../../../domain/services/resume_validator.dart';
import 'item_sheet_scaffold.dart';

Future<Project?> showProjectSheet(
  BuildContext context, {
  required ResumeLanguage language,
  Project? initial,
}) {
  return showItemSheet<Project>(
    context,
    builder: (sheetContext, controller) => _ProjectForm(
      scrollController: controller,
      language: language,
      initial: initial,
    ),
  );
}

class _ProjectForm extends StatefulWidget {
  const _ProjectForm({
    required this.scrollController,
    required this.language,
    required this.initial,
  });

  final ScrollController scrollController;
  final ResumeLanguage language;
  final Project? initial;

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _description;
  late final TextEditingController _technologies;
  late final TextEditingController _url;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _role = TextEditingController(text: initial?.role ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _technologies = TextEditingController(text: initial?.technologies ?? '');
    _url = TextEditingController(text: initial?.url ?? '');
    _startDate = initial?.startDate;
    _endDate = initial?.endDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _description.dispose();
    _technologies.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final url = _url.text.trim();
    Navigator.of(context).pop(
      Project(
        id: widget.initial?.id ?? newId(),
        name: _name.text.trim(),
        role: _role.text.trim().isEmpty ? null : _role.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        technologies: _technologies.text.trim().isEmpty
            ? null
            : _technologies.text.trim(),
        url: url.isEmpty ? null : ResumeValidator.normalizeUrl(url),
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = widget.language.textDirection;

    return ItemSheetBody(
      title: widget.initial == null ? l10n.addProject : l10n.editProject,
      controller: widget.scrollController,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _name,
          label: l10n.fieldProjectName,
          autofocus: widget.initial == null,
          textDirection: content,
        ),
        AppTextField(
          controller: _role,
          label: l10n.fieldRole,
          textDirection: content,
        ),
        AppTextField(
          controller: _description,
          label: l10n.fieldDescription,
          maxLines: 4,
          minLines: 3,
          textDirection: content,
        ),
        AppTextField(
          controller: _technologies,
          label: l10n.fieldTechnologies,
          helper: l10n.fieldTechnologiesHint,
          textDirection: content,
        ),
        AppTextField(
          controller: _url,
          label: '${l10n.fieldProjectUrl} (${l10n.commonOptional})',
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          validator: (value) {
            final trimmed = (value ?? '').trim();
            if (trimmed.isEmpty) return null;
            return ResumeValidator.isValidUrl(trimmed)
                ? null
                : l10n.validationInvalidUrl;
          },
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
                value: _endDate,
                language: widget.language,
                onChanged: (value) => setState(() => _endDate = value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
