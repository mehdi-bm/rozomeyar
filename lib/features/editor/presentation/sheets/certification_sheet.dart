import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/certification.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/services/resume_validator.dart';
import 'item_sheet_scaffold.dart';

Future<Certification?> showCertificationSheet(
  BuildContext context, {
  required ResumeLanguage language,
  Certification? initial,
}) {
  return showItemSheet<Certification>(
    context,
    builder: (sheetContext, controller) => _CertificationForm(
      scrollController: controller,
      language: language,
      initial: initial,
    ),
  );
}

class _CertificationForm extends StatefulWidget {
  const _CertificationForm({
    required this.scrollController,
    required this.language,
    required this.initial,
  });

  final ScrollController scrollController;
  final ResumeLanguage language;
  final Certification? initial;

  @override
  State<_CertificationForm> createState() => _CertificationFormState();
}

class _CertificationFormState extends State<_CertificationForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _organization;
  late final TextEditingController _credentialUrl;
  late final TextEditingController _description;

  DateTime? _issueDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _organization = TextEditingController(text: initial?.organization ?? '');
    _credentialUrl = TextEditingController(text: initial?.credentialUrl ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _issueDate = initial?.issueDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _organization.dispose();
    _credentialUrl.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final url = _credentialUrl.text.trim();
    Navigator.of(context).pop(
      Certification(
        id: widget.initial?.id ?? newId(),
        name: _name.text.trim(),
        organization: _organization.text.trim().isEmpty
            ? null
            : _organization.text.trim(),
        issueDate: _issueDate,
        credentialUrl: url.isEmpty ? null : ResumeValidator.normalizeUrl(url),
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
      title: widget.initial == null
          ? l10n.addCertification
          : l10n.editCertification,
      controller: widget.scrollController,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        AppTextField(
          controller: _name,
          label: l10n.fieldCertificateName,
          autofocus: widget.initial == null,
          textDirection: content,
        ),
        AppTextField(
          controller: _organization,
          label: l10n.fieldOrganization,
          textDirection: content,
        ),
        DateField(
          label: l10n.fieldIssueDate,
          value: _issueDate,
          language: widget.language,
          onChanged: (value) => setState(() => _issueDate = value),
        ),
        AppTextField(
          controller: _credentialUrl,
          label: '${l10n.fieldCredentialUrl} (${l10n.commonOptional})',
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
