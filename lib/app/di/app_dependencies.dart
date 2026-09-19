import '../../data/local/resume_file_store.dart';
import '../../data/local/resume_store.dart';
import '../../data/local/settings_store.dart';
import '../../data/repositories/resume_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../data/services/mlkit_translation_service.dart';
import '../../features/ads/config/ads_config.dart';
import '../../features/ads/data/advertising_service.dart';
import '../../features/ads/data/install_id_repository.dart';
import '../../features/ads/domain/advertising_gateway.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/sample_resume.dart';
import '../../domain/services/translation_service.dart';

/// The app's dependency graph. Small enough that a hand-rolled container beats
/// pulling in a service-locator package.
class AppDependencies {
  const AppDependencies({
    required this.resumeRepository,
    required this.settingsRepository,
    required this.translationService,
    required this.adsConfig,
    required this.advertisingGateway,
    required this.appSupportGateway,
    required this.installIdRepository,
  });

  final ResumeRepository resumeRepository;
  final SettingsRepository settingsRepository;
  final TranslationService translationService;
  final AdsConfig adsConfig;
  final AdvertisingGateway advertisingGateway;
  final AppSupportGateway appSupportGateway;
  final InstallIdRepository installIdRepository;
}

/// Builds and warms the dependency graph. Both stores can be overridden so
/// tests run against a temp directory and in-memory preferences.
Future<AppDependencies> bootstrap({
  ResumeStore? resumeStore,
  SettingsStore? settingsStore,
  TranslationService? translationService,
  AdsConfig? adsConfig,
  AdvertisingGateway? advertisingGateway,
  AppSupportGateway? appSupportGateway,
}) async {
  final resolvedSettingsStore = settingsStore ?? await SettingsStore.open();
  final resolvedResumeStore = resumeStore ?? await ResumeFileStore.open();

  final settingsRepository = SettingsRepositoryImpl(resolvedSettingsStore);
  final resumeRepository = ResumeRepositoryImpl(resolvedResumeStore);

  await resumeRepository.load();
  await _seedSampleIfNeeded(resumeRepository, settingsRepository);

  // Keys come from --dart-define; when they are absent every advertising
  // feature reports itself unconfigured instead of inventing a value.
  final ads = adsConfig ?? AdsConfig.fromEnvironment();

  return AppDependencies(
    resumeRepository: resumeRepository,
    settingsRepository: settingsRepository,
    // ML Kit talks over a platform channel, which never answers under
    // `flutter test`, so tests must inject a fake.
    translationService: translationService ?? MlKitTranslationService(),
    adsConfig: ads,
    advertisingGateway:
        advertisingGateway ?? AdvertisingService(config: ads),
    appSupportGateway: appSupportGateway ?? AppSupportService(config: ads),
    installIdRepository: InstallIdRepository(),
  );
}

/// Seeds «نمونه رزومه» exactly once, and only when the user has nothing yet, so
/// it can never reappear after being deleted or sit alongside real resumes on a
/// later launch.
Future<void> _seedSampleIfNeeded(
  ResumeRepository resumes,
  SettingsRepository settings,
) async {
  if (settings.current.hasSeededSample) return;
  if (resumes.all.isNotEmpty) {
    await settings.markSampleSeeded();
    return;
  }
  await resumes.save(
    SampleResume.build(language: settings.current.defaultResumeLanguage),
  );
  await settings.markSampleSeeded();
}
