import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/enums.dart';
import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import '../utils/date_format.dart';
import 'date_picker_sheet.dart';

/// Standard labelled text input used by every editor form.
///
/// [textDirection] applies to the *typed value*, not the field's chrome: the
/// label and icons keep following the app language, while the content follows
/// the resume language. Without it, English text typed into a Persian UI is
/// right-aligned and trailing punctuation jumps to the wrong end.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.inputFormatters,
    this.textDirection,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction ??
          (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      textDirection: textDirection,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}

/// Read-only field that opens [showResumeDatePicker]. Renders the value in the
/// resume's own calendar so a Persian resume never shows a Gregorian date.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.language,
    required this.onChanged,
    this.includeDay = false,
    this.enabled = true,
    this.placeholder,
  });

  final String label;
  final DateTime? value;
  final ResumeLanguage language;
  final ValueChanged<DateTime?> onChanged;
  final bool includeDay;
  final bool enabled;

  /// Shown instead of a date when [value] is null — e.g. «تاکنون».
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final text = value == null
        ? (placeholder ?? '')
        : (includeDay
              ? AppDateFormat.fullDate(value!, language)
              : AppDateFormat.monthYear(value!, language));

    return InkWell(
      onTap: enabled
          ? () async {
              // Otherwise the text field focused before the picker regains
              // focus when it closes, and the keyboard pops back up over the
              // date fields and the sheet's save button.
              FocusScope.of(context).unfocus();
              final picked = await showResumeDatePicker(
                context,
                language: language,
                title: label,
                initialDate: value,
                includeDay: includeDay,
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      borderRadius: AppRadius.fieldRadius,
      child: InputDecorator(
        isEmpty: text.isEmpty,
        decoration: InputDecoration(
          labelText: label,
          enabled: enabled,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: value != null && enabled
              ? IconButton(
                  tooltip: l10n.commonClear,
                  icon: const Icon(Icons.close),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
