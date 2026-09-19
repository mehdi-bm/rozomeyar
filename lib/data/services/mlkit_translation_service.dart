import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../core/utils/app_failure.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/translation_service.dart';

/// On-device translation via Google ML Kit.
///
/// Models are downloaded once (~30 MB each) and then translation runs entirely
/// on the device — the resume text never leaves the phone, which is why this
/// was chosen over a cloud translation API for a document as personal as a CV.
class MlKitTranslationService implements TranslationService {
  MlKitTranslationService();

  final OnDeviceTranslatorModelManager _models =
      OnDeviceTranslatorModelManager();

  /// Translators are expensive to construct, so one is kept per direction and
  /// closed together in [dispose].
  final Map<String, OnDeviceTranslator> _translators =
      <String, OnDeviceTranslator>{};

  static TranslateLanguage _toMlKit(ResumeLanguage language) =>
      switch (language) {
        ResumeLanguage.persian => TranslateLanguage.persian,
        ResumeLanguage.arabic => TranslateLanguage.arabic,
        ResumeLanguage.english => TranslateLanguage.english,
      };

  @override
  Future<bool> isModelReady(ResumeLanguage language) async {
    return guard(AppFailureKind.translationFailed, () async {
      return _models.isModelDownloaded(_toMlKit(language).bcpCode);
    });
  }

  @override
  Future<bool> downloadModel(ResumeLanguage language) async {
    return guard(AppFailureKind.translationModelDownload, () async {
      // Defaults to Wi-Fi only, which silently refuses on mobile data and is
      // indistinguishable from having no connection at all.
      return _models.downloadModel(
        _toMlKit(language).bcpCode,
        isWifiRequired: false,
      );
    });
  }

  @override
  Future<void> deleteModel(ResumeLanguage language) async {
    return guard(AppFailureKind.translationFailed, () async {
      await _models.deleteModel(_toMlKit(language).bcpCode);
    });
  }

  @override
  Future<String> translate(
    String text, {
    required ResumeLanguage from,
    required ResumeLanguage to,
  }) async {
    if (from == to) return text;
    if (text.trim().isEmpty) return text;

    return guard(AppFailureKind.translationFailed, () async {
      final translator = _translators.putIfAbsent(
        '${from.code}>${to.code}',
        () => OnDeviceTranslator(
          sourceLanguage: _toMlKit(from),
          targetLanguage: _toMlKit(to),
        ),
      );
      final result = await translator.translateText(text);
      // An empty result means the model had nothing to offer; keeping the
      // original beats silently blanking a resume field.
      return result.trim().isEmpty ? text : result;
    });
  }

  @override
  Future<void> dispose() async {
    for (final translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
  }
}
