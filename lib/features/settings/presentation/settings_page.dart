import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/enums.dart';
import '../../ads/presentation/advertising_request_page.dart';
import '../../ads/presentation/error_report_page.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: <Widget>[
              _SectionHeader(title: l10n.settingsSectionGeneral),
              _ChoiceTile<String>(
                icon: Icons.language_outlined,
                title: l10n.settingsAppLanguage,
                value: settings.appLanguageCode,
                valueLabel: settings.appLanguageCode == 'en'
                    ? 'English'
                    : 'فارسی',
                options: const <String>['fa', 'en'],
                labelFor: (code) => code == 'en' ? 'English' : 'فارسی',
                onSelected: cubit.setAppLanguage,
              ),
              _ChoiceTile<AppThemeMode>(
                icon: Icons.brightness_6_outlined,
                title: l10n.settingsTheme,
                value: settings.themeMode,
                valueLabel: _themeLabel(l10n, settings.themeMode),
                options: AppThemeMode.values,
                labelFor: (mode) => _themeLabel(l10n, mode),
                onSelected: cubit.setThemeMode,
              ),
              _ChoiceTile<ResumeLanguage>(
                icon: Icons.translate_outlined,
                title: l10n.settingsDefaultResumeLanguage,
                value: settings.defaultResumeLanguage,
                valueLabel: _resumeLanguageLabel(
                  l10n,
                  settings.defaultResumeLanguage,
                ),
                options: ResumeLanguage.values,
                labelFor: (language) => _resumeLanguageLabel(l10n, language),
                onSelected: cubit.setDefaultResumeLanguage,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: l10n.settingsSectionAbout),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAbout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.about),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l10n.errorReportTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ErrorReportPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(l10n.advertisingRequestTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdvertisingRequestPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.settingsPrivacy),
                subtitle: Text(l10n.privacyLocalStorage),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacy),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _themeLabel(AppLocalizations l10n, AppThemeMode mode) =>
      switch (mode) {
        AppThemeMode.system => l10n.themeSystem,
        AppThemeMode.light => l10n.themeLight,
        AppThemeMode.dark => l10n.themeDark,
      };

  static String _resumeLanguageLabel(
    AppLocalizations l10n,
    ResumeLanguage language,
  ) => resumeLanguageLabel(l10n, language);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// A settings row that opens a radio bottom sheet — one widget for all three
/// single-choice preferences.
class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueLabel,
    required this.options,
    required this.labelFor,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final T value;
  final String valueLabel;
  final List<T> options;
  final String Function(T) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(valueLabel),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showModalBottomSheet<T>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
                RadioGroup<T>(
                  groupValue: value,
                  onChanged: (selection) =>
                      Navigator.of(sheetContext).pop(selection),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final option in options)
                        RadioListTile<T>(
                          value: option,
                          title: Text(labelFor(option)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
        if (selected != null) onSelected(selected);
      },
    );
  }
}
