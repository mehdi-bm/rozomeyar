import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/list_reorder.dart';
import '../../../../domain/models/certification.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../sheets/certification_sheet.dart';
import '../widgets/editor_section.dart';

class CertificationsStep extends StatelessWidget {
  const CertificationsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume.certifications != current.resume.certifications,
      builder: (context, state) {
        final cubit = context.read<ResumeEditorCubit>();
        final language = state.resume.language;

        return EditorSection(
          title: l10n.stepCertifications,
          children: <Widget>[
            SectionItemList<Certification>(
              items: state.resume.certifications,
              emptyMessage: l10n.emptyCertifications,
              addLabel: l10n.addCertification,
              titleOf: (item) => item.name,
              subtitleOf: (item) => item.organization,
              trailingOf: (item) => item.issueDate == null
                  ? null
                  : AppDateFormat.monthYear(item.issueDate!, language),
              onAdd: () async {
                final created = await showCertificationSheet(
                  context,
                  language: language,
                );
                if (created == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    certifications: <Certification>[
                      ...resume.certifications,
                      created,
                    ],
                  ),
                );
              },
              onEdit: (item) async {
                final updated = await showCertificationSheet(
                  context,
                  language: language,
                  initial: item,
                );
                if (updated == null) return;
                cubit.edit(
                  (resume) => resume.copyWith(
                    certifications: resume.certifications
                        .map((e) => e.id == updated.id ? updated : e)
                        .toList(),
                  ),
                );
              },
              onDelete: (item) => cubit.edit(
                (resume) => resume.copyWith(
                  certifications: resume.certifications
                      .where((e) => e.id != item.id)
                      .toList(),
                ),
              ),
              onReorder: (oldIndex, newIndex) => cubit.edit(
                (resume) => resume.copyWith(
                  certifications: reordered(
                    resume.certifications,
                    oldIndex,
                    newIndex,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
