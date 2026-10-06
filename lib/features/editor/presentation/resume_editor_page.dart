import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../cubit/resume_editor_cubit.dart';
import 'steps/certifications_step.dart';
import 'steps/education_step.dart';
import 'steps/experience_step.dart';
import 'steps/languages_step.dart';
import 'steps/links_step.dart';
import 'steps/personal_info_step.dart';
import 'steps/projects_step.dart';
import 'steps/review_step.dart';
import 'steps/skills_step.dart';
import 'steps/summary_step.dart';
import 'steps/template_step.dart';

class ResumeEditorPage extends StatefulWidget {
  const ResumeEditorPage({super.key});

  @override
  State<ResumeEditorPage> createState() => _ResumeEditorPageState();
}

class _ResumeEditorPageState extends State<ResumeEditorPage>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _index = 0;

  static const List<Widget> _steps = <Widget>[
    PersonalInfoStep(),
    SummaryStep(),
    ExperienceStep(),
    EducationStep(),
    SkillsStep(),
    LanguagesStep(),
    ProjectsStep(),
    CertificationsStep(),
    LinksStep(),
    TemplateStep(),
    ReviewStep(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final cubit = context.read<ResumeEditorCubit>();
      if (cubit.state.hasPendingChanges) cubit.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  List<String> _labels(AppLocalizations l10n) => <String>[
    l10n.stepPersonalInfo,
    l10n.stepSummary,
    l10n.stepExperience,
    l10n.stepEducation,
    l10n.stepSkills,
    l10n.stepLanguages,
    l10n.stepProjects,
    l10n.stepCertifications,
    l10n.stepLinks,
    l10n.stepTemplate,
    l10n.stepPreview,
  ];

  void _goTo(int index) {
    if (index < 0 || index >= _steps.length) return;
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      index,
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final labels = _labels(l10n);

    return BlocListener<ResumeEditorCubit, ResumeEditorState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && current.failure != null,
      listener: (context, state) =>
          showFailureSnackBar(context, state.failure!),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
            buildWhen: (previous, current) =>
                previous.resume.title != current.resume.title,
            builder: (context, state) => Text(
              state.resume.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(84),
            child: _StepBar(
              labels: labels,
              currentIndex: _index,
              onSelected: _goTo,
            ),
          ),
          actions: <Widget>[
            BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
              buildWhen: (previous, current) =>
                  previous.isSaving != current.isSaving ||
                  previous.hasPendingChanges != current.hasPendingChanges,
              builder: (context, state) {
                final saving = state.isSaving || state.hasPendingChanges;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Center(
                    child: saving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            Icons.cloud_done_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _index = index),
          children: _steps,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                if (_index > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _goTo(_index - 1),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(l10n.commonBack),
                    ),
                  ),
                if (_index > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index == _steps.length - 1
                        ? null
                        : () => _goTo(_index + 1),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(l10n.commonNext),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable step indicator; tapping a step jumps straight to it
/// so the editor never feels like a forced wizard.
class _StepBar extends StatefulWidget {
  const _StepBar({
    required this.labels,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_StepBar> createState() => _StepBarState();
}

class _StepBarState extends State<_StepBar> {
  final ScrollController _controller = ScrollController();

  @override
  void didUpdateWidget(_StepBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToCurrent();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Keeps the active chip on screen as the user advances. The estimate is
  /// deliberately rough — it only needs to land in the right neighbourhood.
  void _scrollToCurrent() {
    if (!_controller.hasClients) return;
    const estimatedChipWidth = 116.0;
    final target = (widget.currentIndex * estimatedChipWidth) - 80;
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: AppDurations.normal,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 44,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: widget.labels.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final selected = index == widget.currentIndex;
              final done = index < widget.currentIndex;
              return Center(
                child: ChoiceChip(
                  label: Text(widget.labels[index]),
                  selected: selected,
                  showCheckmark: false,
                  avatar: done
                      ? Icon(Icons.check, size: 16, color: scheme.primary)
                      : null,
                  onSelected: (_) => widget.onSelected(index),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Text(
                l10n.stepProgress(
                  widget.currentIndex + 1,
                  widget.labels.length,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (widget.currentIndex + 1) / widget.labels.length,
                    minHeight: 4,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
