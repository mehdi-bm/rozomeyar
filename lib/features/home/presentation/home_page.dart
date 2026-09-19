import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../data/excel/resume_backup_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/models/resume.dart';
import '../../../domain/services/translation_service.dart';
import '../../ads/cubit/ad_banner_cubit.dart';
import '../../ads/presentation/ad_banner_widget.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../translation/presentation/translate_resume_sheet.dart';
import '../cubit/resume_list_cubit.dart';
import 'widgets/create_resume_sheet.dart';
import 'widgets/resume_card.dart';
import 'widgets/resume_filter_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ResumeFilter _filter = const ResumeFilter.all();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.backupImport,
            onPressed: () => _import(context),
            icon: const Icon(Icons.file_upload_outlined),
          ),
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Collapses to zero height when there is no active campaign.
          const AdBannerWidget(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<AdBannerCubit>().load(force: true),
              child: BlocBuilder<ResumeListCubit, List<Resume>>(
                builder: (context, resumes) {
                  if (resumes.isEmpty) {
                    return _HomeEmptyState(onCreate: () => _create(context));
                  }

                  final filters = availableFilters(resumes);
                  // The selected filter can disappear — the last favourite
                  // gets unstarred, the last Arabic resume is deleted — so
                  // fall back rather than showing an empty list forever.
                  final active = filters.contains(_filter)
                      ? _filter
                      : const ResumeFilter.all();
                  final visible =
                      resumes.where(active.matches).toList(growable: false);

                  return Column(
                    children: <Widget>[
                      ResumeFilterBar(
                        filters: filters,
                        selected: active,
                        countFor: (filter) =>
                            resumes.where(filter.matches).length,
                        onSelected: (filter) =>
                            setState(() => _filter = filter),
                      ),
                      Expanded(
                        child: visible.isEmpty
                            ? _FilterEmptyState(
                                onShowAll: () => setState(
                                  () => _filter = const ResumeFilter.all(),
                                ),
                              )
                            : _ResumeList(resumes: visible),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ResumeListCubit, List<Resume>>(
        builder: (context, resumes) {
          if (resumes.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.homeCreateCta),
          );
        },
      ),
    );
  }

  /// Restores a resume from an exported workbook. The imported resume is always
  /// added alongside the existing ones, never merged into them.
  static Future<void> _import(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<ResumeListCubit>();
    try {
      final imported = await const ResumeBackupService().pickAndImport();
      if (imported == null || !context.mounted) return;

      final failure = await cubit.add(imported);
      if (!context.mounted) return;
      if (failure != null) {
        showFailureSnackBar(context, failure);
        return;
      }
      showAppSnackBar(context, l10n.backupImported);
      context.push(AppRoutes.resumeEdit(imported.id));
    } on AppFailure catch (failure) {
      if (context.mounted) showFailureSnackBar(context, failure.kind);
    } on FormatException {
      if (context.mounted) {
        showFailureSnackBar(context, AppFailureKind.backupImport);
      }
    }
  }

  static Future<void> _create(BuildContext context) async {
    final defaultLanguage = context
        .read<SettingsCubit>()
        .state
        .defaultResumeLanguage;
    final result = await showCreateResumeSheet(
      context,
      defaultLanguage: defaultLanguage,
    );
    if (result == null || !context.mounted) return;

    final (resume, failure) = await context.read<ResumeListCubit>().create(
      title: result.title,
      language: result.language,
    );
    if (!context.mounted) return;
    if (failure != null) {
      showFailureSnackBar(context, failure);
      return;
    }
    if (resume != null) context.push(AppRoutes.resumeEdit(resume.id));
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      // Always scrollable so pull-to-refresh works even when the content is
      // shorter than the viewport.
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: l10n.homeEmptyTitle,
          subtitle: l10n.homeEmptySubtitle,
          action: FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(l10n.homeCreateCta),
          ),
        ),
      ),
    );
  }
}

/// Shown when a filter matches nothing — distinct from the "no resumes at
/// all" state, because the fix here is to clear the filter, not to create.
class _FilterEmptyState extends StatelessWidget {
  const _FilterEmptyState({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: EmptyState(
          compact: true,
          icon: Icons.filter_alt_off_outlined,
          title: l10n.filterEmpty,
          action: TextButton(
            onPressed: onShowAll,
            child: Text(l10n.filterShowAll),
          ),
        ),
      ),
    );
  }
}

class _ResumeList extends StatelessWidget {
  const _ResumeList({required this.resumes});

  final List<Resume> resumes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        // Room for the extended FAB.
        AppSpacing.xxxl + AppSpacing.xl,
      ),
      itemCount: resumes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final resume = resumes[index];
        return ResumeCard(
          resume: resume,
          onOpen: () => context.push(AppRoutes.resumeEdit(resume.id)),
          onAction: (action) => _handleAction(context, resume, action),
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Resume resume,
    ResumeCardAction action,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<ResumeListCubit>();

    switch (action) {
      case ResumeCardAction.edit:
        context.push(AppRoutes.resumeEdit(resume.id));
      case ResumeCardAction.preview:
        context.push(AppRoutes.resumePreview(resume.id));
      case ResumeCardAction.toggleFavorite:
        final favoriteFailure = await cubit.toggleFavorite(resume);
        if (!context.mounted) return;
        _report(context, favoriteFailure);
      case ResumeCardAction.translate:
        final translated = await showTranslateResumeSheet(
          context,
          resume: resume,
          service: context.read<TranslationService>(),
        );
        if (translated == null || !context.mounted) return;
        // The sheet only builds the translated resume; persisting it is the
        // repository's job, so a failed save surfaces like any other.
        final failure = await cubit.add(translated);
        if (!context.mounted) return;
        if (failure == null) {
          showAppSnackBar(context, l10n.translateDone);
          context.push(AppRoutes.resumeEdit(translated.id));
        } else {
          showFailureSnackBar(context, failure);
        }
      case ResumeCardAction.exportExcel:
        try {
          await const ResumeBackupService().share(resume);
        } on AppFailure catch (failure) {
          if (context.mounted) showFailureSnackBar(context, failure.kind);
        }
      case ResumeCardAction.rename:
        final title = await showRenameResumeDialog(
          context,
          initialTitle: resume.title,
        );
        if (title == null || !context.mounted) return;
        final renameFailure = await cubit.rename(resume, title);
        if (!context.mounted) return;
        _report(context, renameFailure);
      case ResumeCardAction.duplicate:
        final failure = await cubit.duplicate(
          resume.id,
          copySuffix: l10n.homeCopySuffix,
        );
        if (!context.mounted) return;
        if (failure == null) {
          showAppSnackBar(context, l10n.homeDuplicated);
        } else {
          showFailureSnackBar(context, failure);
        }
      case ResumeCardAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.homeDeleteTitle,
          message: l10n.homeDeleteMessage(resume.title),
          confirmLabel: l10n.commonDelete,
        );
        if (!confirmed || !context.mounted) return;
        final failure = await cubit.delete(resume.id);
        if (!context.mounted) return;
        if (failure == null) {
          showAppSnackBar(context, l10n.homeDeleted);
        } else {
          showFailureSnackBar(context, failure);
        }
    }
  }

  void _report(BuildContext context, AppFailureKind? failure) {
    if (failure != null && context.mounted) {
      showFailureSnackBar(context, failure);
    }
  }
}
