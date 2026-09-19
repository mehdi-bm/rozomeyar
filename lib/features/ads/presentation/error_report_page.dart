import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/form_fields.dart';
import '../domain/advertising_gateway.dart';
import '../domain/ads_failure.dart';
import 'ads_failure_messages.dart';
import 'ads_validators.dart';

class ErrorReportPage extends StatefulWidget {
  const ErrorReportPage({super.key});

  @override
  State<ErrorReportPage> createState() => _ErrorReportPageState();
}

class _ErrorReportPageState extends State<ErrorReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final gateway = context.read<AppSupportGateway>();

    setState(() => _sending = true);
    try {
      await gateway.submitErrorReport(description: _description.text);
      if (!mounted) return;
      // Only cleared once the server has actually accepted it.
      _description.clear();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.errorReportSent)));
    } on AdsFailure catch (failure) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.kind.message(l10n))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final configured = context.read<AppSupportGateway>().isConfigured;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorReportTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    l10n.errorReportIntro,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const ValueKey('error_description'),
                controller: _description,
                label: l10n.errorReportDescription,
                hint: l10n.errorReportHint,
                maxLines: 8,
                minLines: 5,
                maxLength: AdsValidators.descriptionMax,
                validator: (value) =>
                    AdsValidators.isValidDescription(value ?? '')
                    ? null
                    : l10n.errorReportTooShort,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!configured)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    l10n.adsNotConfigured,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                key: const ValueKey('submit_error_report'),
                onPressed: (_sending || !configured) ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.errorReportSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
