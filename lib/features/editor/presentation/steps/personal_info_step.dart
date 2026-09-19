import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../../core/widgets/photo_picker_avatar.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/personal_info.dart';
import '../../../../domain/services/resume_validator.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../widgets/editor_section.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _jobTitle;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _city;
  late final TextEditingController _country;
  late final TextEditingController _address;

  @override
  bool get wantKeepAlive => true;

  ResumeEditorCubit get _cubit => context.read<ResumeEditorCubit>();

  @override
  void initState() {
    super.initState();
    // Controllers are seeded once; the cubit is the source of truth from then
    // on, so typing never triggers a rebuild of this subtree.
    final info = context.read<ResumeEditorCubit>().state.resume.personalInfo;
    _firstName = TextEditingController(text: info.firstName);
    _lastName = TextEditingController(text: info.lastName);
    _jobTitle = TextEditingController(text: info.jobTitle);
    _mobile = TextEditingController(text: info.mobile ?? '');
    _email = TextEditingController(text: info.email ?? '');
    _city = TextEditingController(text: info.city ?? '');
    _country = TextEditingController(text: info.country ?? '');
    _address = TextEditingController(text: info.address ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _jobTitle.dispose();
    _mobile.dispose();
    _email.dispose();
    _city.dispose();
    _country.dispose();
    _address.dispose();
    super.dispose();
  }

  void _updateInfo(PersonalInfo Function(PersonalInfo info) transform) {
    _cubit.edit(
      (resume) =>
          resume.copyWith(personalInfo: transform(resume.personalInfo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final resume = context.read<ResumeEditorCubit>().state.resume;
    // Content is typed in the resume's language, which may differ from the UI's.
    final content = resume.language.textDirection;

    return EditorSection(
      title: l10n.stepPersonalInfo,
      children: <Widget>[
        Center(
          child: BlocSelector<ResumeEditorCubit, ResumeEditorState, String?>(
            selector: (state) => state.resume.personalInfo.photoPath,
            builder: (context, photoPath) => PhotoPickerAvatar(
              photoPath: photoPath,
              onChanged: (path) => _updateInfo(
                (info) => path == null
                    ? info.copyWith(clearPhoto: true)
                    : info.copyWith(photoPath: path),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: _firstName,
          label: l10n.fieldFirstName,
          textDirection: content,
          onChanged: (value) => _updateInfo((i) => i.copyWith(firstName: value)),
          validator: (value) => ResumeValidator.isBlank(value)
              ? l10n.validationFirstNameRequired
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _lastName,
          label: l10n.fieldLastName,
          textDirection: content,
          onChanged: (value) => _updateInfo((i) => i.copyWith(lastName: value)),
          validator: (value) => ResumeValidator.isBlank(value)
              ? l10n.validationLastNameRequired
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _jobTitle,
          label: l10n.fieldJobTitle,
          hint: l10n.fieldJobTitleHint,
          textDirection: content,
          onChanged: (value) => _updateInfo((i) => i.copyWith(jobTitle: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _mobile,
          label: l10n.fieldMobile,
          keyboardType: TextInputType.phone,
          // Phone numbers read left-to-right in every language, matching how
          // the PDF renders them.
          textDirection: TextDirection.ltr,
          onChanged: (value) => _updateInfo((i) => i.copyWith(mobile: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _email,
          label: l10n.fieldEmail,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          onChanged: (value) => _updateInfo((i) => i.copyWith(email: value)),
          validator: (value) {
            final trimmed = (value ?? '').trim();
            if (trimmed.isEmpty) return null;
            return ResumeValidator.isValidEmail(trimmed)
                ? null
                : l10n.validationInvalidEmail;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                controller: _city,
                label: l10n.fieldCity,
                textDirection: content,
                onChanged: (value) => _updateInfo((i) => i.copyWith(city: value)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _country,
                label: l10n.fieldCountry,
                textDirection: content,
                onChanged: (value) =>
                    _updateInfo((i) => i.copyWith(country: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.optionalFieldsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.optionalFieldsSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _OptionalFields(
          language: resume.language,
          addressController: _address,
          onAddressChanged: (value) =>
              _updateInfo((i) => i.copyWith(address: value)),
        ),
      ],
    );
  }
}

/// Optional personal details, each paired with a "show in resume" switch.
class _OptionalFields extends StatelessWidget {
  const _OptionalFields({
    required this.language,
    required this.addressController,
    required this.onAddressChanged,
  });

  final ResumeLanguage language;
  final TextEditingController addressController;
  final ValueChanged<String> onAddressChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocSelector<ResumeEditorCubit, ResumeEditorState, PersonalInfo>(
      selector: (state) => state.resume.personalInfo,
      builder: (context, info) {
        final cubit = context.read<ResumeEditorCubit>();
        void update(PersonalInfo Function(PersonalInfo) transform) {
          cubit.edit(
            (resume) =>
                resume.copyWith(personalInfo: transform(resume.personalInfo)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DateField(
              label: l10n.fieldBirthDate,
              value: info.dateOfBirth,
              language: language,
              includeDay: true,
              onChanged: (value) => update(
                (i) => value == null
                    ? i.copyWith(clearDateOfBirth: true)
                    : i.copyWith(dateOfBirth: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: info.visibility.showDateOfBirth,
              title: Text(l10n.optionalFieldsTitle),
              onChanged: info.dateOfBirth == null
                  ? null
                  : (value) => update(
                      (i) => i.copyWith(
                        visibility: i.visibility.copyWith(
                          showDateOfBirth: value,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: addressController,
              label: l10n.fieldAddress,
              maxLines: 2,
              minLines: 1,
              textDirection: language.textDirection,
              onChanged: onAddressChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: info.visibility.showAddress,
              title: Text(l10n.optionalFieldsTitle),
              onChanged: (value) => update(
                (i) => i.copyWith(
                  visibility: i.visibility.copyWith(showAddress: value),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.fieldMaritalStatus,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final status in MaritalStatus.values)
                  ChoiceChip(
                    label: Text(
                      status == MaritalStatus.single
                          ? l10n.maritalSingle
                          : l10n.maritalMarried,
                    ),
                    selected: info.maritalStatus == status,
                    onSelected: (selected) => update(
                      (i) => selected
                          ? i.copyWith(maritalStatus: status)
                          : i.copyWith(clearMaritalStatus: true),
                    ),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: info.visibility.showMaritalStatus,
              title: Text(l10n.optionalFieldsTitle),
              onChanged: info.maritalStatus == null
                  ? null
                  : (value) => update(
                      (i) => i.copyWith(
                        visibility: i.visibility.copyWith(
                          showMaritalStatus: value,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
