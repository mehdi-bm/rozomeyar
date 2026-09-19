import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../domain/models/enums.dart';
import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import '../utils/date_format.dart';

/// Date picker that speaks the resume's own calendar.
///
/// Flutter's `showDatePicker` is Gregorian-only, which is wrong for a Persian
/// resume, and no well-maintained Jalali calendar widget exists. Resume dates
/// are month-precision anyway, so a compact wheel picker is both simpler and a
/// better fit than a full month grid — [includeDay] adds a day wheel for the
/// few fields (date of birth) that need one.
Future<DateTime?> showResumeDatePicker(
  BuildContext context, {
  required ResumeLanguage language,
  required String title,
  DateTime? initialDate,
  bool includeDay = false,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (sheetContext) => _DatePickerSheet(
      language: language,
      title: title,
      initialDate: initialDate ?? DateTime.now(),
      includeDay: includeDay,
    ),
  );
}

const List<String> _gregorianMonthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({
    required this.language,
    required this.title,
    required this.initialDate,
    required this.includeDay,
  });

  final ResumeLanguage language;
  final String title;
  final DateTime initialDate;
  final bool includeDay;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late final List<int> _years;
  late int _year;
  late int _month;
  late int _day;

  bool get _isJalali => widget.language == ResumeLanguage.persian;

  @override
  void initState() {
    super.initState();
    final nowYear = _isJalali
        ? Jalali.now().year
        : DateTime.now().year;
    _years = List<int>.generate(96, (index) => nowYear - 80 + index);

    if (_isJalali) {
      final jalali = Jalali.fromDateTime(widget.initialDate);
      _year = jalali.year;
      _month = jalali.month;
      _day = jalali.day;
    } else {
      _year = widget.initialDate.year;
      _month = widget.initialDate.month;
      _day = widget.initialDate.day;
    }
    _year = _year.clamp(_years.first, _years.last);
  }

  int get _daysInMonth {
    if (_isJalali) return Jalali(_year, _month).monthLength;
    return DateTime(_year, _month + 1, 0).day;
  }

  DateTime get _selected {
    final day = _day.clamp(1, _daysInMonth);
    if (_isJalali) return Jalali(_year, _month, day).toDateTime();
    return DateTime(_year, _month, day);
  }

  String _label(int value) =>
      _isJalali ? AppDateFormat.toPersianDigits('$value') : '$value';

  String _monthName(int month) {
    if (_isJalali) return Jalali(_year, month).formatter.mN;
    return _gregorianMonthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 180,
              child: Row(
                children: <Widget>[
                  if (widget.includeDay)
                    Expanded(
                      child: _Wheel(
                        // Rebuild the day wheel when month length changes.
                        key: ValueKey<int>(_daysInMonth),
                        itemCount: _daysInMonth,
                        initialIndex: (_day - 1).clamp(0, _daysInMonth - 1),
                        labelFor: (index) => _label(index + 1),
                        onSelected: (index) =>
                            setState(() => _day = index + 1),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: _Wheel(
                      itemCount: 12,
                      initialIndex: _month - 1,
                      labelFor: (index) => _monthName(index + 1),
                      onSelected: (index) =>
                          setState(() => _month = index + 1),
                    ),
                  ),
                  Expanded(
                    child: _Wheel(
                      itemCount: _years.length,
                      initialIndex: _years.indexOf(_year),
                      labelFor: (index) => _label(_years[index]),
                      onSelected: (index) =>
                          setState(() => _year = _years[index]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text(l10n.commonSelect),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  const _Wheel({
    super.key,
    required this.itemCount,
    required this.initialIndex,
    required this.labelFor,
    required this.onSelected,
  });

  final int itemCount;
  final int initialIndex;
  final String Function(int index) labelFor;
  final ValueChanged<int> onSelected;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.initialIndex.clamp(0, widget.itemCount - 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 40,
      perspective: 0.003,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: widget.onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.itemCount,
        builder: (context, index) => Center(
          child: Text(
            widget.labelFor(index),
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
