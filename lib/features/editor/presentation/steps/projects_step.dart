import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/project.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/project_sheet.dart';
import '../widgets/editor_section.dart';

class ProjectsStep extends StatelessWidget {
  const ProjectsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.projects != current.resume.projects,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();
        final language = state.resume.language;

        return EditorSection(
          title: l10n.stepProjects,
          children: <Widget>[
            SectionItemList<Project>(
              items: state.resume.projects,
              emptyMessage: l10n.emptyProjects,
              addLabel: l10n.addProject,
              titleOf: (item) => item.name,
              subtitleOf: (item) => item.role,
              trailingOf: (item) => item.technologies,
              onAdd: () async {
                final created = await showProjectSheet(
                  context,
                  language: language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    projects: <Project>[...resume.projects, created],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showProjectSheet(
                  context,
                  language: language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    projects: resume.projects
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  projects: resume.projects
                      .where((e) => e.id != item.id)
                      .toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  projects: reordered(resume.projects, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
