import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/skill.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/skill_sheet.dart';
import '../widgets/editor_section.dart';

class SkillsStep extends StatelessWidget {
  const SkillsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.skills != current.resume.skills ||
          previous.resume.templateSettings.showSkillLevels !=
              current.resume.templateSettings.showSkillLevels,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();

        return EditorSection(
          title: l10n.stepSkills,
          children: <Widget>[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.resume.templateSettings.showSkillLevels,
              title: Text(l10n.skillsShowLevels),
              onChanged: (value) => cubit.edit(
                (resume) => resume.copyWith(
                  templateSettings: resume.templateSettings.copyWith(
                    showSkillLevels: value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionItemList<Skill>(
              items: state.resume.skills,
              emptyMessage: l10n.emptySkills,
              addLabel: l10n.addSkill,
              titleOf: (item) => item.name,
              subtitleOf: (item) => item.level == null
                  ? null
                  : skillLevelLabel(l10n, item.level!),
              onAdd: () async {
                final created = await showSkillSheet(
                  context,
                  language: state.resume.language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) =>
                      resume.copyWith(skills: <Skill>[...resume.skills, created]),
                );
              },
              onEdit: (item) async {
                final updated = await showSkillSheet(
                  context,
                  language: state.resume.language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    skills: resume.skills
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  skills: resume.skills.where((e) => e.id != item.id).toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  skills: reordered(resume.skills, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
