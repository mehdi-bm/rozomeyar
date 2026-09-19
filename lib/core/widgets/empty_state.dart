import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Shared illustration + title + subtitle + optional CTA used by the home
/// screen and every empty editor section.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  /// Denser variant for inline use inside an editor section.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final circleSize = compact ? 64.0 : 104.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: compact ? AppSpacing.xl : AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: circleSize * 0.45,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: (compact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)
                ?.copyWith(color: scheme.onSurface),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...<Widget>[
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
