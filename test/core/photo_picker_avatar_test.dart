import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/l10n/l10n.dart';
import 'package:resumeyar/core/widgets/photo_picker_avatar.dart';

void main() {
  testWidgets('a missing photo shows a placeholder without an image error', (
    tester,
  ) async {
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
          body: PhotoPickerAvatar(
            photoPath: '${Directory.systemTemp.path}/missing_resume_photo.png',
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing a photo leaves cleanup to the repository', (
    tester,
  ) async {
    late Directory directory;
    late File photo;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('resume_avatar_test');
      photo = await File('${directory.path}/photo.png').writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jF1kAAAAASUVORK5CYII=',
        ),
      );
    });
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await directory.delete(recursive: true);
      });
    });
    String? selected = photo.path;
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
          body: PhotoPickerAvatar(
            photoPath: photo.path,
            onChanged: (path) => selected = path,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('تغییر عکس'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('حذف عکس'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(await tester.runAsync(photo.exists), isTrue);
    expect(tester.takeException(), isNull);
  });
}
