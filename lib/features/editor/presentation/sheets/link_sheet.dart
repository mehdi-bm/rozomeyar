import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/ids.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/resume_link.dart';
import '../../../../domain/services/resume_validator.dart';
import 'item_sheet_scaffold.dart';

String linkTypeLabel(AppLocalizations l10n, LinkType type) => switch (type) {
  LinkType.linkedin => l10n.linkTypeLinkedin,
  LinkType.github => l10n.linkTypeGithub,
  LinkType.portfolio => l10n.linkTypePortfolio,
  LinkType.website => l10n.linkTypeWebsite,
  LinkType.telegram => l10n.linkTypeTelegram,
  LinkType.other => l10n.linkTypeOther,
};

Future<ResumeLink?> showLinkSheet(
  BuildContext context, {
  required ResumeLanguage language,
  ResumeLink? initial,
}) {
  return showCompactItemSheet<ResumeLink>(
    context,
    builder: (sheetContext) => _LinkForm(initial: initial, language: language),
  );
}

class _LinkForm extends StatefulWidget {
  const _LinkForm({required this.initial, required this.language});

  final ResumeLink? initial;
  final ResumeLanguage language;

  @override
  State<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _url;
  late LinkType _type;

  /// True while the title still mirrors the type's default label, so switching
  /// type keeps updating it — but a title the user typed is never overwritten.
  bool _titleFollowsType = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? LinkType.linkedin;
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _url = TextEditingController(text: widget.initial?.url ?? '');
    _titleFollowsType = widget.initial == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_titleFollowsType && _title.text.isEmpty) {
      _title.text = linkTypeLabel(context.l10n, _type);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final url = _url.text.trim();
    if (url.isEmpty) return;
    Navigator.of(context).pop(
      ResumeLink(
        id: widget.initial?.id ?? newId(),
        type: _type,
        title: _title.text.trim().isEmpty
            ? linkTypeLabel(context.l10n, _type)
            : _title.text.trim(),
        url: ResumeValidator.normalizeUrl(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CompactItemSheetBody(
      title: widget.initial == null ? l10n.addLink : l10n.editLink,
      formKey: _formKey,
      onSave: _save,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.linkTypeLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final type in LinkType.values)
              ChoiceChip(
                label: Text(linkTypeLabel(l10n, type)),
                selected: _type == type,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _type = type;
                    if (_titleFollowsType) {
                      _title.text = linkTypeLabel(l10n, type);
                    }
                  });
                },
              ),
          ],
        ),
        AppTextField(
          controller: _title,
          label: l10n.fieldLinkTitle,
          textDirection: widget.language.textDirection,
          onChanged: (_) => _titleFollowsType = false,
        ),
        AppTextField(
          controller: _url,
          label: l10n.fieldLinkUrl,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) return l10n.validationRequired;
            return ResumeValidator.isValidUrl(value!)
                ? null
                : l10n.validationInvalidUrl;
          },
        ),
      ],
    );
  }
}
