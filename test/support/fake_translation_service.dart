import 'package:resumeyar/core/utils/app_failure.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/services/translation_service.dart';

/// In-memory [TranslationService] for tests.
///
/// The real one talks over a platform channel, which never answers under
/// `flutter test` — an awaiting future simply hangs forever rather than
/// throwing, so tests must never touch it.
class FakeTranslationService implements TranslationService {
  FakeTranslationService({
    Set<ResumeLanguage>? readyModels,
    this.downloadSucceeds = true,
    this.translateThrows = false,
  }) : _ready = readyModels ?? <ResumeLanguage>{};

  final Set<ResumeLanguage> _ready;

  bool downloadSucceeds;
  bool translateThrows;

  /// Every string handed to [translate], in call order.
  final List<String> requested = <String>[];

  final List<ResumeLanguage> downloaded = <ResumeLanguage>[];

  @override
  Future<bool> isModelReady(ResumeLanguage language) async =>
      _ready.contains(language);

  @override
  Future<bool> downloadModel(ResumeLanguage language) async {
    if (!downloadSucceeds) return false;
    downloaded.add(language);
    _ready.add(language);
    return true;
  }

  @override
  Future<void> deleteModel(ResumeLanguage language) async {
    _ready.remove(language);
  }

  @override
  Future<String> translate(
    String text, {
    required ResumeLanguage from,
    required ResumeLanguage to,
  }) async {
    if (translateThrows) {
      throw AppFailure(AppFailureKind.translationFailed);
    }
    requested.add(text);
    // A recognisable, reversible marker: assertions can check both that a field
    // was translated and that the original text reached the service.
    return '[${to.code}]$text';
  }

  @override
  Future<void> dispose() async {}
}
