import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared chrome for every "add / edit item" modal sheet.
///
/// Sheets are draggable and scrollable so long forms stay usable with the
/// keyboard open.
Future<T?> showItemSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context, ScrollController controller)
  builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: builder,
    ),
  );
}

/// Height-hugging variant for short forms (skill, language, link) where the
/// full draggable sheet would be mostly empty space.
Future<T?> showCompactItemSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: builder,
  );
}

/// Body for [showCompactItemSheet]: title, fields, save button, no scroll view
/// of its own beyond keyboard avoidance.
class CompactItemSheetBody extends StatelessWidget {
  const CompactItemSheetBody({
    super.key,
    required this.title,
    required this.formKey,
    required this.onSave,
    required this.children,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            for (final child in children) ...<Widget>[
              child,
              const SizedBox(height: AppSpacing.lg),
            ],
            FilledButton(onPressed: onSave, child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );
  }
}

class ItemSheetBody extends StatelessWidget {
  const ItemSheetBody({
    super.key,
    required this.title,
    required this.controller,
    required this.formKey,
    required this.onSave,
    required this.children,
  });

  final String title;
  final ScrollController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(title, style: theme.textTheme.titleLarge),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Form(
            key: formKey,
            child: ListView(
              controller: controller,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
              ),
              children: <Widget>[
                for (final child in children) ...<Widget>[
                  child,
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSave,
                child: Text(l10n.commonSave),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
