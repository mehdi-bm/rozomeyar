import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final points = <(IconData, String)>[
      (Icons.phone_android_outlined, l10n.privacyLocalStorage),
      (Icons.cloud_off_outlined, l10n.privacyBody),
      (Icons.person_off_outlined, l10n.privacyNoAccount),
      (Icons.wifi_off_outlined, l10n.privacyNoInternet),
      (Icons.translate_outlined, l10n.privacyTranslation),
      (Icons.photo_camera_outlined, l10n.privacyPermissions),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView.separated(
        padding: AppSpacing.pagePadding,
        itemCount: points.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final (icon, text) = points[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(text, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
