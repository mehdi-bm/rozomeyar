import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/form_fields.dart';
import '../domain/advertising_gateway.dart';
import '../domain/ads_failure.dart';
import 'ads_failure_messages.dart';
import 'ads_validators.dart';

class AdvertisingRequestPage extends StatefulWidget {
  const AdvertisingRequestPage({super.key});

  /// Below this the province and city fields stack instead of sharing a row.
  static const double _wideBreakpoint = 420;

  @override
  State<AdvertisingRequestPage> createState() => _AdvertisingRequestPageState();
}

class _AdvertisingRequestPageState extends State<AdvertisingRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _province = TextEditingController();
  final _city = TextEditingController();
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _province.dispose();
    _city.dispose();
    _details.dispose();
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
      await gateway.submitAdvertisingRequest(
        fullName: _fullName.text,
        // Digits normalised so a Persian-keyboard number reaches the API as
        // something it can parse.
        phoneNumber: AdsValidators.normalizeDigits(_phone.text),
        province: _province.text,
        city: _city.text,
        details: _details.text,
      );
      if (!mounted) return;
      for (final controller in <TextEditingController>[
        _fullName,
        _phone,
        _province,
        _city,
        _details,
      ]) {
        controller.clear();
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.advertisingRequestSent)));
    } on AdsFailure catch (failure) {
      if (!mounted) return;
      // Input is deliberately left intact so the user can retry.
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

    final province = AppTextField(
      key: const ValueKey('advertising_province'),
      controller: _province,
      label: l10n.advertisingProvince,
      maxLength: AdsValidators.regionMax,
      validator: (value) => AdsValidators.isValidRegion(value ?? '')
          ? null
          : l10n.advertisingRegionInvalid,
    );
    final city = AppTextField(
      key: const ValueKey('advertising_city'),
      controller: _city,
      label: l10n.advertisingCity,
      maxLength: AdsValidators.regionMax,
      validator: (value) => AdsValidators.isValidRegion(value ?? '')
          ? null
          : l10n.advertisingRegionInvalid,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.advertisingRequestTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: <Widget>[
              AppTextField(
                key: const ValueKey('advertising_full_name'),
                controller: _fullName,
                label: l10n.advertisingFullName,
                maxLength: AdsValidators.fullNameMax,
                validator: (value) => AdsValidators.isValidFullName(value ?? '')
                    ? null
                    : l10n.advertisingFullNameInvalid,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const ValueKey('advertising_phone'),
                controller: _phone,
                label: l10n.advertisingPhone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                // Digits of any script, plus the usual separators.
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9۰-۹٠-٩+\-() ]'),
                  ),
                ],
                validator: (value) => AdsValidators.isValidPhone(value ?? '')
                    ? null
                    : l10n.advertisingPhoneInvalid,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth <
                      AdvertisingRequestPage._wideBreakpoint) {
                    return Column(
                      children: <Widget>[
                        province,
                        const SizedBox(height: AppSpacing.lg),
                        city,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: province),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: city),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const ValueKey('advertising_details'),
                controller: _details,
                label: l10n.advertisingDetails,
                maxLines: 5,
                minLines: 3,
                maxLength: AdsValidators.detailsMax,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.advertisingPrivacy,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                key: const ValueKey('submit_advertising_request'),
                onPressed: (_sending || !configured) ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.advertisingSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
