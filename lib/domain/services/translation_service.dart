import '../models/enums.dart';

/// Where a translation model lives right now.
enum TranslationModelState {
  /// Present on the device — translating needs no network at all.
  ready,

  /// Not downloaded yet; a one-off download over the network is required.
  missing,

  downloading,
}

/// Translates resume text between [ResumeLanguage]s.
///
/// Deliberately abstract: the UI must not import ML Kit, and tests must not
/// touch a platform channel (a real one hangs forever under `flutter test`).
abstract interface class TranslationService {
  /// Whether the model for [language] is already on the device.
  Future<bool> isModelReady(ResumeLanguage language);

  /// Downloads the model for [language]. Returns false if it could not be
  /// fetched — almost always no connectivity.
  ///
  /// This is the *only* part of translation that uses the network.
  Future<bool> downloadModel(ResumeLanguage language);

  /// Removes a downloaded model so the user can reclaim the space.
  Future<void> deleteModel(ResumeLanguage language);

  /// Translates a single string. Returns the input unchanged when it holds
  /// nothing worth translating.
  Future<String> translate(
    String text, {
    required ResumeLanguage from,
    required ResumeLanguage to,
  });

  /// Releases any native resources held open between calls.
  Future<void> dispose();
}
