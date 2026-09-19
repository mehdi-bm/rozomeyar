import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/education.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/education_sheet.dart';
import '../widgets/editor_section.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.educations != current.resume.educations,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();
        final language = state.resume.language;

        return EditorSection(
          title: l10n.stepEducation,
          children: <Widget>[
            SectionItemList<Education>(
              items: state.resume.educations,
              emptyMessage: l10n.emptyEducation,
              addLabel: l10n.addEducation,
              titleOf: (item) => item.headline,
              subtitleOf: (item) => item.institution,
              trailingOf: (item) => AppDateFormat.range(
                start: item.startDate,
                end: item.endDate,
                isCurrent: item.isCurrent,
                language: language,
                presentLabel: l10n.dateNow,
              ),
              onAdd: () async {
                final created = await showEducationSheet(
                  context,
                  language: language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    educations: <Education>[...resume.educations, created],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showEducationSheet(
                  context,
                  language: language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    educations: resume.educations
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  educations: resume.educations
                      .where((e) => e.id != item.id)
                      .toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  educations: reordered(resume.educations, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
