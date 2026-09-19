import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/models/section_item.dart';

/// Shared chrome for every editor step: a title, a short explanation and the
/// step body.
class EditorSection extends StatelessWidget {
  const EditorSection({
    super.key,
    required this.title,
    required this.children,
    this.description,
  });

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: <Widget>[
        Text(title, style: theme.textTheme.titleLarge),
        if (description != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }
}

/// Reorderable list of repeatable section entries with add/edit/delete.
///
/// Every repeatable step (experience, education, skills, ...) shares this so the
/// interaction model is identical throughout the editor.
class SectionItemList<T extends SectionItem> extends StatelessWidget {
  const SectionItemList({
    super.key,
    required this.items,
    required this.emptyMessage,
    required this.addLabel,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    required this.titleOf,
    this.subtitleOf,
    this.trailingOf,
    this.reorderable = true,
  });

  final List<T> items;
  final String emptyMessage;
  final String addLabel;
  final VoidCallback onAdd;
  final ValueChanged<T> onEdit;
  final ValueChanged<T> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final String Function(T item) titleOf;
  final String? Function(T item)? subtitleOf;
  final String? Function(T item)? trailingOf;
  final bool reorderable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (items.isEmpty)
          EmptyState(
            compact: true,
            icon: Icons.inbox_outlined,
            title: emptyMessage,
            subtitle: l10n.emptySectionHint,
          )
        else ...<Widget>[
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: onReorder,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                key: ValueKey<String>(item.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ItemCard<T>(
                  index: index,
                  title: titleOf(item),
                  subtitle: subtitleOf?.call(item),
                  trailing: trailingOf?.call(item),
                  reorderable: reorderable && items.length > 1,
                  onEdit: () => onEdit(item),
                  onDelete: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: l10n.deleteItemTitle,
                      message: l10n.deleteItemMessage,
                      confirmLabel: l10n.commonDelete,
                    );
                    if (confirmed) onDelete(item);
                  },
                ),
              );
            },
          ),
          if (reorderable && items.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                l10n.reorderHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(addLabel),
        ),
      ],
    );
  }
}

class _ItemCard<T> extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.reorderable,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool reorderable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (reorderable)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(
                      Icons.drag_indicator,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title.isEmpty ? '—' : title,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (trailing != null && trailing!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        trailing!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.commonDelete,
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: scheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
