import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../cubit/resume_editor_cubit.dart';
import '../widgets/editor_section.dart';

class SummaryStep extends StatefulWidget {
  const SummaryStep({super.key});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;
  late int _characterCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final summary =
        context.read<ResumeEditorCubit>().state.resume.professionalSummary;
    _controller = TextEditingController(text: summary);
    _characterCount = summary.characters.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return EditorSection(
      title: l10n.stepSummary,
      description: l10n.summaryRecommendation,
      children: <Widget>[
        AppTextField(
          controller: _controller,
          label: l10n.summaryTitle,
          hint: l10n.summaryHint,
          maxLines: 10,
          minLines: 6,
          textDirection: context
              .read<ResumeEditorCubit>()
              .state
              .resume
              .language
              .textDirection,
          onChanged: (value) {
            context.read<ResumeEditorCubit>().edit(
              (resume) => resume.copyWith(professionalSummary: value),
            );
            // Only the counter depends on this, so the rebuild is cheap.
            setState(() => _characterCount = value.characters.length);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            l10n.summaryCharCount(_characterCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
