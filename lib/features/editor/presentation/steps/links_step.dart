import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/resume_link.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/link_sheet.dart';
import '../widgets/editor_section.dart';

class LinksStep extends StatelessWidget {
  const LinksStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.links != current.resume.links,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();

        return EditorSection(
          title: l10n.stepLinks,
          children: <Widget>[
            SectionItemList<ResumeLink>(
              items: state.resume.links,
              emptyMessage: l10n.emptyLinks,
              addLabel: l10n.addLink,
              titleOf: (item) => item.title,
              subtitleOf: (item) => item.url,
              onAdd: () async {
                final created = await showLinkSheet(
                  context,
                  language: state.resume.language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    links: <ResumeLink>[...resume.links, created],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showLinkSheet(
                  context,
                  language: state.resume.language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    links: resume.links
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  links: resume.links.where((e) => e.id != item.id).toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  links: reordered(resume.links, oldIndex, newIndex),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
