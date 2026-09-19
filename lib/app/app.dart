import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../domain/models/app_settings.dart';
import '../domain/repositories/resume_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/services/translation_service.dart';
import '../features/ads/cubit/ad_banner_cubit.dart';
import '../features/ads/domain/advertising_gateway.dart';
import '../features/home/cubit/resume_list_cubit.dart';
import '../features/settings/cubit/settings_cubit.dart';
import 'di/app_dependencies.dart';

class ResumeYarApp extends StatefulWidget {
  const ResumeYarApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ResumeYarApp> createState() => _ResumeYarAppState();
}

class _ResumeYarAppState extends State<ResumeYarApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<ResumeRepository>.value(
          value: widget.dependencies.resumeRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: widget.dependencies.settingsRepository,
        ),
        RepositoryProvider<TranslationService>.value(
          value: widget.dependencies.translationService,
        ),
        RepositoryProvider<AppSupportGateway>.value(
          value: widget.dependencies.appSupportGateway,
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<SettingsCubit>(
            create: (_) =>
                SettingsCubit(widget.dependencies.settingsRepository),
          ),
          BlocProvider<ResumeListCubit>(
            create: (_) =>
                ResumeListCubit(widget.dependencies.resumeRepository),
          ),
          // App-wide so the banner keeps its 20-minute cache across
          // navigation instead of refetching on every return to home.
          BlocProvider<AdBannerCubit>(
            create: (_) => AdBannerCubit(
              gateway: widget.dependencies.advertisingGateway,
              installIds: widget.dependencies.installIdRepository,
            )..load(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          buildWhen: (previous, current) =>
              previous.appLanguageCode != current.appLanguageCode ||
              previous.themeMode != current.themeMode,
          builder: (context, settings) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => context.l10n.appTitle,
              routerConfig: _router,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.themeMode.themeMode,
              locale: AppLocales.fromCode(settings.appLanguageCode),
              supportedLocales: AppLocales.supported,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
