import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/resume.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../widgets/editor_section.dart';

/// Final editor step: a readiness checklist plus the entry point to the real
/// PDF preview.
///
/// The preview itself lives on its own screen rather than inside this
/// `PageView`, so a full PDF is not re-rendered every time the user swipes
/// through the editor.
class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      builder: (context, state) {
        final resume = state.resume;
        final checks = <(String, bool)>[
          (l10n.stepPersonalInfo, _hasName(resume)),
          (l10n.stepSummary, resume.hasSummary),
          (l10n.stepExperience, resume.visibleExperiences.isNotEmpty),
          (l10n.stepEducation, resume.visibleEducations.isNotEmpty),
          (l10n.stepSkills, resume.visibleSkills.isNotEmpty),
          (l10n.stepLanguages, resume.visibleLanguages.isNotEmpty),
          (l10n.stepProjects, resume.visibleProjects.isNotEmpty),
          (l10n.stepCertifications, resume.visibleCertifications.isNotEmpty),
          (l10n.stepLinks, resume.visibleLinks.isNotEmpty),
        ];

        return EditorSection(
          title: l10n.stepPreview,
          description: l10n.emptySectionHint,
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  for (final (label, done) in checks)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: done
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        size: 20,
                      ),
                      title: Text(label, style: theme.textTheme.bodyMedium),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () async {
                final cubit = context.read<ResumeEditorCubit>();
                // Flush pending edits so the preview renders the latest text.
                await cubit.save();
                if (!context.mounted || cubit.state.failure != null) return;
                await context.push(AppRoutes.resumePreview(resume.id));
                // The preview has its own cubit and may have changed the
                // template, so pick those changes up before editing resumes.
                if (!cubit.isClosed) cubit.reload();
              },
              icon: const Icon(Icons.visibility_outlined),
              label: Text(l10n.commonPreview),
            ),
          ],
        );
      },
    );
  }

  static bool _hasName(Resume resume) =>
      resume.personalInfo.firstName.trim().isNotEmpty &&
      resume.personalInfo.lastName.trim().isNotEmpty;
}
