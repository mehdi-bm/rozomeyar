import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/experience.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/experience_sheet.dart';
import '../widgets/editor_section.dart';

class ExperienceStep extends StatelessWidget {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.experiences != current.resume.experiences,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();
        final language = state.resume.language;
        final items = state.resume.experiences;

        return EditorSection(
          title: l10n.stepExperience,
          children: <Widget>[
            SectionItemList<Experience>(
              items: items,
              emptyMessage: l10n.emptyExperience,
              addLabel: l10n.addExperience,
              titleOf: (item) => item.jobTitle,
              subtitleOf: (item) => item.company,
              trailingOf: (item) => AppDateFormat.range(
                start: item.startDate,
                end: item.endDate,
                isCurrent: item.isCurrent,
                language: language,
                presentLabel: l10n.dateNow,
              ),
              onAdd: () async {
                final created = await showExperienceSheet(
                  context,
                  language: language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    experiences: <Experience>[...resume.experiences, created],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showExperienceSheet(
                  context,
                  language: language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    experiences: resume.experiences
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  experiences: resume.experiences
                      .where((e) => e.id != item.id)
                      .toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  experiences: reordered(resume.experiences, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
