import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/resume_language_item.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/language_sheet.dart';
import '../widgets/editor_section.dart';

class LanguagesStep extends StatelessWidget {
  const LanguagesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.languages != current.resume.languages,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();

        return EditorSection(
          title: l10n.stepLanguages,
          children: <Widget>[
            SectionItemList<ResumeLanguageItem>(
              items: state.resume.languages,
              emptyMessage: l10n.emptyLanguages,
              addLabel: l10n.addLanguage,
              titleOf: (item) => item.name,
              subtitleOf: (item) => languageLevelLabel(l10n, item.level),
              onAdd: () async {
                final created = await showLanguageSheet(
                  context,
                  language: state.resume.language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    languages: <ResumeLanguageItem>[
                      ...resume.languages,
                      created,
                    ],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showLanguageSheet(
                  context,
                  language: state.resume.language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    languages: resume.languages
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  languages: resume.languages
                      .where((e) => e.id != item.id)
                      .toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  languages: reordered(resume.languages, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
