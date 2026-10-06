import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/l10n/l10n.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/features/editor/presentation/sheets/language_sheet.dart';
import 'package:resumeyar/features/editor/presentation/sheets/experience_sheet.dart';
import 'package:resumeyar/features/editor/presentation/sheets/link_sheet.dart';
import 'package:resumeyar/features/editor/presentation/sheets/skill_sheet.dart';
import 'package:resumeyar/features/home/presentation/widgets/create_resume_sheet.dart';

void main() {
  final forms = <String, Future<Object?> Function(BuildContext)>{
    'create resume': (context) =>
        showCreateResumeSheet(context, defaultLanguage: ResumeLanguage.persian),
    'skill': (context) =>
        showSkillSheet(context, language: ResumeLanguage.persian),
    'language': (context) =>
        showLanguageSheet(context, language: ResumeLanguage.persian),
    'link': (context) =>
        showLinkSheet(context, language: ResumeLanguage.persian),
    'experience': (context) =>
        showExperienceSheet(context, language: ResumeLanguage.persian),
  };

  for (final entry in forms.entries) {
    testWidgets('${entry.key} fits a small phone with the keyboard open', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fa'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => entry.value(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // The submit action must remain reachable without closing the keyboard.
      final submit = find.byType(FilledButton).last;
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.getRect(submit).bottom, lessThanOrEqualTo(340));
    });
  }
}
