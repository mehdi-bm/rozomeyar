import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import '../l10n/l10n.dart';
import '../utils/app_failure.dart';

extension AppFailureMessage on AppFailureKind {
  String message(AppLocalizations l10n) => switch (this) {
    AppFailureKind.storageRead => l10n.errorStorageRead,
    AppFailureKind.storageWrite => l10n.errorStorageWrite,
    AppFailureKind.pdfGeneration => l10n.errorPdfGeneration,
    AppFailureKind.imagePick => l10n.errorImagePick,
    AppFailureKind.share => l10n.errorShare,
    AppFailureKind.resumeNotFound => l10n.errorResumeNotFound,
    AppFailureKind.translationModelDownload => l10n.errorTranslationDownload,
    AppFailureKind.translationFailed => l10n.errorTranslationFailed,
    AppFailureKind.backupImport => l10n.errorBackupImport,
    AppFailureKind.unknown => l10n.errorGeneric,
  };
}

/// The resume language's name in the *app* language — used wherever the UI
/// talks about a resume's language, which is not the same as the UI's own.
String resumeLanguageLabel(AppLocalizations l10n, ResumeLanguage language) =>
    switch (language) {
      ResumeLanguage.persian => l10n.resumeLanguagePersian,
      ResumeLanguage.arabic => l10n.resumeLanguageArabic,
      ResumeLanguage.english => l10n.resumeLanguageEnglish,
    };

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showFailureSnackBar(BuildContext context, AppFailureKind kind) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          kind.message(context.l10n),
          style: TextStyle(color: scheme.onErrorContainer),
        ),
        backgroundColor: scheme.errorContainer,
        closeIconColor: scheme.onErrorContainer,
        showCloseIcon: true,
      ),
    );
}
