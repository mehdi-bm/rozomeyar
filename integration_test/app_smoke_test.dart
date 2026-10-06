import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:resumeyar/app/app.dart';
import 'package:resumeyar/app/di/app_dependencies.dart';
import 'package:resumeyar/data/excel/resume_backup_service.dart';
import 'package:resumeyar/data/excel/resume_workbook.dart';
import 'package:resumeyar/data/local/resume_file_store.dart';
import 'package:resumeyar/data/local/settings_store.dart';
import 'package:resumeyar/data/repositories/resume_repository_impl.dart';
import 'package:resumeyar/data/services/mlkit_translation_service.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';
import 'package:resumeyar/pdf/resume_pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'device: editing, disk persistence, PDF raster and Excel backup',
    (tester) async {
      // Resume files stay isolated from the user's actual documents.
      final temporary = await getTemporaryDirectory();
      final directory = await Directory(
        '${temporary.path}/device_smoke_'
        '${DateTime.now().microsecondsSinceEpoch}',
      ).create();
      final store = ResumeFileStore(
        root: Directory('${directory.path}/resumes'),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final translation = MlKitTranslationService();
      final dependencies = await bootstrap(
        resumeStore: store,
        settingsStore: await SettingsStore.open(),
        translationService: translation,
      );
      final repository = dependencies.resumeRepository as ResumeRepositoryImpl;
      addTearDown(() async {
        await translation.dispose();
        await repository.dispose();
        await directory.delete(recursive: true);
      });

      await tester.pumpWidget(ResumeYarApp(dependencies: dependencies));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('نمونه رزومه'), findsWidgets);

      await tester.tap(find.text('ویرایش').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'نام'),
        'Device',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final id = repository.all.single.id;
      expect((await store.read(id))!.personalInfo.firstName, 'Device');

      for (var step = 1; step < 11; step++) {
        await tester.tap(find.text('بعدی'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'editor step ${step + 1}',
        );
      }

      const pdf = ResumePdfService();
      for (final language in <ResumeLanguage>[
        ResumeLanguage.persian,
        ResumeLanguage.english,
        ResumeLanguage.arabic,
      ]) {
        for (final template in TemplateId.values) {
          final sample = SampleResume.build(language: language);
          final resume = sample.copyWith(
            templateSettings: sample.templateSettings.copyWith(
              templateId: template,
            ),
            personalInfo: sample.personalInfo.copyWith(
              firstName: 'device_test_${DateTime.now().microsecondsSinceEpoch}',
            ),
          );
          final bytes = await pdf.build(resume);
          final page = await Printing.raster(
            bytes,
            pages: <int>[0],
            dpi: 72,
          ).first;
          expect(page.width, greaterThan(0));
          expect((await page.toPng()).length, greaterThan(1000));
          final exported = await pdf.saveToFile(resume, bytes);
          expect(await exported.length(), bytes.length);
          await exported.delete();
        }
      }

      final resume = repository.all.single;
      final workbook = await const ResumeBackupService().export(
        resume.copyWith(
          title: 'device_test_${DateTime.now().microsecondsSinceEpoch}',
          personalInfo: resume.personalInfo.copyWith(
            firstName: 'device_test_${DateTime.now().microsecondsSinceEpoch}',
          ),
        ),
      );
      final restored = ResumeWorkbook.decode(await workbook.readAsBytes());
      expect(restored.personalInfo.firstName, startsWith('device_test_'));
      expect(restored.id, isNot(resume.id));
      await workbook.delete();

      // Exercises the actual ML Kit channel without downloading language packs.
      expect(
        await translation.isModelReady(ResumeLanguage.persian),
        isA<bool>(),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
