import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/app/app.dart';
import 'package:resumeyar/app/di/app_dependencies.dart';
import 'package:resumeyar/data/local/settings_store.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/domain/repositories/resume_repository.dart';
import 'package:resumeyar/features/home/presentation/widgets/resume_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_translation_service.dart';
import 'support/in_memory_resume_store.dart';

void main() {
  late InMemoryResumeStore store;
  late FakeTranslationService translation;

  setUp(() {
    store = InMemoryResumeStore();
    // The real ML Kit service would reach a platform channel that never
    // answers in tests.
    translation = FakeTranslationService(
      readyModels: <ResumeLanguage>{...ResumeLanguage.values},
    );
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppDependencies> buildDependencies() async => bootstrap(
    resumeStore: store,
    settingsStore: await SettingsStore.open(),
    translationService: translation,
  );

  /// Pumps past the splash screen's minimum-display timer onto the home screen.
  Future<AppDependencies> pumpApp(WidgetTester tester) async {
    final dependencies = await buildDependencies();
    await tester.pumpWidget(ResumeYarApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('first launch seeds the sample resume and shows it on home', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);

    expect(dependencies.resumeRepository.all, hasLength(1));
    expect(dependencies.resumeRepository.all.single.isSample, isTrue);
    expect(find.text('نمونه رزومه'), findsWidgets);
  });

  testWidgets('the sample resume is not re-seeded on a later launch', (
    tester,
  ) async {
    final first = await buildDependencies();
    await first.resumeRepository.delete(first.resumeRepository.all.single.id);

    final second = await pumpApp(tester);

    expect(second.resumeRepository.all, isEmpty);
    expect(find.text('هنوز رزومه‌ای نساخته‌اید'), findsOneWidget);
    expect(find.text('اولین رزومه حرفه‌ای خود را بسازید'), findsOneWidget);
  });

  testWidgets('creating a resume from the empty state opens the editor', (
    tester,
  ) async {
    final first = await buildDependencies();
    await first.resumeRepository.delete(first.resumeRepository.all.single.id);

    final dependencies = await pumpApp(tester);

    await tester.tap(find.text('ساخت رزومه جدید').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'رزومه تست');
    await tester.pumpAndSettle();

    await tester.tap(find.text('ساخت رزومه جدید').last);
    await tester.pumpAndSettle();

    expect(dependencies.resumeRepository.all, hasLength(1));
    expect(dependencies.resumeRepository.all.single.title, 'رزومه تست');
    // The editor opened on its first step.
    expect(find.text('اطلاعات شخصی'), findsWidgets);
  });

  testWidgets('editor input autosaves without an explicit save action', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);
    final resumeId = dependencies.resumeRepository.all.single.id;

    await tester.tap(find.text('ویرایش').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'نام'), 'سارا');
    // Let the autosave debounce elapse.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(
      dependencies.resumeRepository.byId(resumeId)!.personalInfo.firstName,
      'سارا',
    );
  });

  testWidgets('backgrounding the editor immediately saves pending input', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);
    final id = dependencies.resumeRepository.all.single.id;
    await tester.tap(find.text('ویرایش').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'نام'), 'سارا');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(
      dependencies.resumeRepository.byId(id)!.personalInfo.firstName,
      'سارا',
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets('editor state survives moving between steps', (tester) async {
    final dependencies = await pumpApp(tester);
    final resumeId = dependencies.resumeRepository.all.single.id;

    await tester.tap(find.text('ویرایش').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'نام'), 'سارا');
    await tester.pumpAndSettle();

    // Step forward to "درباره من" and back again.
    await tester.tap(find.text('بعدی'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('قبلی'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'نام'), findsOneWidget);
    expect(find.text('سارا'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(
      dependencies.resumeRepository.byId(resumeId)!.personalInfo.firstName,
      'سارا',
    );
  });

  testWidgets('starring a resume reveals a filter that narrows the list', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);
    // A second resume in another language, so language chips appear too.
    await dependencies.resumeRepository.save(
      Resume(
        id: 'en-1',
        title: 'English CV',
        language: ResumeLanguage.english,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
    await tester.pumpAndSettle();

    // Nothing is starred yet, so no favourites chip.
    expect(find.text('ستاره‌دار (0)'), findsNothing);
    expect(find.text('همه (2)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();

    expect(find.text('ستاره‌دار (1)'), findsOneWidget);

    await tester.tap(find.text('ستاره‌دار (1)'));
    await tester.pumpAndSettle();

    // Only the starred resume survives the filter.
    expect(find.byType(ResumeCard), findsOneWidget);
  });

  testWidgets('deleting a resume asks for confirmation first', (tester) async {
    final dependencies = await pumpApp(tester);
    final ResumeRepository repository = dependencies.resumeRepository;

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف').last);
    await tester.pumpAndSettle();

    expect(find.text('حذف رزومه'), findsOneWidget);
    expect(repository.all, hasLength(1), reason: 'nothing deleted yet');

    await tester.tap(find.widgetWithText(FilledButton, 'حذف'));
    await tester.pumpAndSettle();

    expect(repository.all, isEmpty);
  });

  testWidgets('duplicating a resume adds an independent copy', (tester) async {
    final dependencies = await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تهیه کپی').last);
    await tester.pumpAndSettle();

    final all = dependencies.resumeRepository.all;
    expect(all, hasLength(2));
    expect(all.map((r) => r.id).toSet(), hasLength(2));
  });

  group('editor text direction follows the resume, not the app', () {
    /// Reads the direction the field will lay its typed text out with.
    TextDirection? directionOf(WidgetTester tester, String label) {
      return tester
          .widget<TextField>(
            find.descendant(
              of: find.widgetWithText(TextFormField, label),
              matching: find.byType(TextField),
            ),
          )
          .textDirection;
    }

    Future<void> openEditorFor(
      WidgetTester tester,
      ResumeLanguage language,
    ) async {
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'ساخت رزومه جدید'),
      );
      await tester.pumpAndSettle();
      // Scoped to the picker: the same language name also appears on the
      // resume cards behind the sheet.
      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<ResumeLanguage>),
          matching: find.text(
            language == ResumeLanguage.english ? 'انگلیسی' : 'فارسی',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ساخت رزومه جدید').last);
      await tester.pumpAndSettle();
    }

    testWidgets('an English resume types left-to-right in a Persian UI', (
      tester,
    ) async {
      await pumpApp(tester);
      await openEditorFor(tester, ResumeLanguage.english);

      expect(directionOf(tester, 'نام'), TextDirection.ltr);
      expect(directionOf(tester, 'عنوان شغلی'), TextDirection.ltr);
    });

    testWidgets('a Persian resume still types right-to-left', (tester) async {
      await pumpApp(tester);
      await openEditorFor(tester, ResumeLanguage.persian);

      expect(directionOf(tester, 'نام'), TextDirection.rtl);
      expect(directionOf(tester, 'عنوان شغلی'), TextDirection.rtl);
    });

    testWidgets('phone stays left-to-right regardless of resume language', (
      tester,
    ) async {
      // A tall surface so the whole personal-info step is laid out at once —
      // a ListView does not build fields that are below the fold.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      await openEditorFor(tester, ResumeLanguage.persian);

      // Numbers read LTR in every language, matching how the PDF prints them.
      expect(directionOf(tester, 'شماره موبایل'), TextDirection.ltr);
      expect(directionOf(tester, 'ایمیل'), TextDirection.ltr);
      // ...while the surrounding content still follows the resume.
      expect(directionOf(tester, 'شهر'), TextDirection.rtl);
    });
  });

  testWidgets('translating a resume creates a second, translated resume', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);
    final original = dependencies.resumeRepository.all.single;

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ترجمه رزومه').last);
    await tester.pumpAndSettle();

    // Persian source, so only Arabic and English are offered as targets.
    // Checked on the control itself — "فارسی" also appears on the card behind
    // the sheet, so a plain text finder would be misleading.
    final segmented = tester.widget<SegmentedButton<ResumeLanguage>>(
      find.byType(SegmentedButton<ResumeLanguage>),
    );
    expect(segmented.segments.map((s) => s.value).toSet(), <ResumeLanguage>{
      ResumeLanguage.arabic,
      ResumeLanguage.english,
    });

    await tester.tap(find.text('انگلیسی'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('شروع ترجمه'));
    await tester.pumpAndSettle();

    final all = dependencies.resumeRepository.all;
    expect(all, hasLength(2), reason: 'the original must be kept');
    expect(all.any((r) => r.id == original.id), isTrue);

    final translated = all.firstWhere((r) => r.id != original.id);
    expect(translated.language, ResumeLanguage.english);
    expect(translated.isSample, isFalse);
    expect(
      translated.personalInfo.firstName,
      startsWith('[en]'),
      reason: 'fields should have gone through the translator',
    );
  });

  testWidgets('switching the app language to English relocalizes the UI', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('زبان برنامه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('App language'), findsOneWidget);
  });

  testWidgets('the default resume language drives the create sheet', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);
    await dependencies.settingsRepository.setDefaultResumeLanguage(
      ResumeLanguage.english,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'ساخت رزومه جدید'),
    );
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<ResumeLanguage>>(
      find.byType(SegmentedButton<ResumeLanguage>),
    );
    expect(segmented.selected, <ResumeLanguage>{ResumeLanguage.english});
  });
}
