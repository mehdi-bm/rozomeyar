import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/resume_repository.dart';
import '../../features/editor/cubit/resume_editor_cubit.dart';
import '../../features/editor/presentation/resume_editor_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/preview/presentation/preview_page.dart';
import '../../features/settings/presentation/about_page.dart';
import '../../features/settings/presentation/privacy_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import '../widgets/empty_state.dart';
import 'app_routes.dart';

/// Builds a fresh router per app instance.
///
/// A single top-level `GoRouter` would carry its current location across app
/// restarts in tests, so each `ResumeYarApp` gets its own.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: AppRoutes.resumeEditPattern,
        builder: (context, state) => _ResumeScope(
          id: state.pathParameters['id'],
          child: const ResumeEditorPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resumePreviewPattern,
        builder: (context, state) => _ResumeScope(
          id: state.pathParameters['id'],
          child: const PreviewPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => const _RouteNotFoundPage(),
  );
}

/// Loads the resume for a route and provides a [ResumeEditorCubit] to it.
///
/// Both the editor and the preview edit the same resume, so they share one
/// cubit type — changing a template from the preview autosaves exactly like an
/// edit made in the editor.
class _ResumeScope extends StatelessWidget {
  const _ResumeScope({required this.id, required this.child});

  final String? id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ResumeRepository>();
    final resume = id == null ? null : repository.byId(id!);

    if (resume == null) return const _ResumeNotFoundPage();

    return BlocProvider<ResumeEditorCubit>(
      create: (_) =>
          ResumeEditorCubit(repository: repository, initial: resume),
      child: child,
    );
  }
}

class _ResumeNotFoundPage extends StatelessWidget {
  const _ResumeNotFoundPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: EmptyState(
          icon: Icons.search_off_outlined,
          title: l10n.errorResumeNotFound,
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.homeTitle),
          ),
        ),
      ),
    );
  }
}

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: EmptyState(
            icon: Icons.error_outline,
            title: l10n.errorGeneric,
            action: FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(l10n.homeTitle),
            ),
          ),
        ),
      ),
    );
  }
}
