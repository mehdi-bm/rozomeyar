import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/app_failure.dart';
import 'package:resumeyar/data/local/resume_file_store.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';

void main() {
  late Directory tempDir;
  late ResumeFileStore store;

  Resume makeResume(String id, {DateTime? updatedAt}) {
    final now = updatedAt ?? DateTime(2026, 1, 1);
    return Resume(
      id: id,
      title: 'رزومه $id',
      createdAt: now,
      updatedAt: now,
      personalInfo: const PersonalInfo(firstName: 'مهدی', lastName: 'محمدی'),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumeyar_store_test');
    store = ResumeFileStore(root: Directory('${tempDir.path}/resumes'));
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('readAll on a fresh install returns an empty list', () async {
    expect(await store.readAll(), isEmpty);
  });

  test('write then read returns an equal resume', () async {
    final resume = makeResume('a');
    await store.write(resume);

    expect(await store.read('a'), resume);
  });

  test('readAll returns most-recently-updated first', () async {
    await store.write(makeResume('old', updatedAt: DateTime(2026, 1, 1)));
    await store.write(makeResume('new', updatedAt: DateTime(2026, 6, 1)));
    await store.write(makeResume('mid', updatedAt: DateTime(2026, 3, 1)));

    final ids = (await store.readAll()).map((r) => r.id).toList();
    expect(ids, <String>['new', 'mid', 'old']);
  });

  test('read returns null for an unknown id', () async {
    expect(await store.read('nope'), isNull);
  });

  test('delete removes the file', () async {
    await store.write(makeResume('a'));
    await store.delete('a');

    expect(await store.read('a'), isNull);
    expect(await store.readAll(), isEmpty);
  });

  test('delete of a missing id is a no-op', () async {
    await store.delete('ghost');
    expect(await store.readAll(), isEmpty);
  });

  test('writing twice overwrites rather than duplicating', () async {
    await store.write(makeResume('a'));
    await store.write(
      makeResume('a').copyWith(title: 'به‌روزشده'),
    );

    final all = await store.readAll();
    expect(all, hasLength(1));
    expect(all.single.title, 'به‌روزشده');
  });

  test('a corrupt file is skipped instead of failing the whole list', () async {
    await store.write(makeResume('good'));
    await File('${store.root.path}/broken.json').writeAsString('{not json');

    final all = await store.readAll();
    expect(all.map((r) => r.id), <String>['good']);
  });

  test('non-json files in the directory are ignored', () async {
    await store.write(makeResume('good'));
    await File('${store.root.path}/notes.txt').writeAsString('hello');

    expect(await store.readAll(), hasLength(1));
  });

  test('no temporary file is left behind after a write', () async {
    await store.write(makeResume('a'));

    final names = store.root.listSync().map((e) => e.path).toList();
    expect(names.where((n) => n.endsWith('.tmp')), isEmpty);
  });

  test('stored json carries the current schema version', () async {
    await store.write(makeResume('a'));

    final raw = await File('${store.root.path}/a.json').readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    expect(json['schemaVersion'], Resume.currentSchemaVersion);
  });

  test('a document written without a version still loads', () async {
    final json = makeResume('a').toJson()..remove('schemaVersion');
    await File('${store.root.path}/a.json').create(recursive: true);
    await File('${store.root.path}/a.json').writeAsString(jsonEncode(json));

    final resume = await store.read('a');
    expect(resume, isNotNull);
    expect(resume!.schemaVersion, Resume.currentSchemaVersion);
  });

  test('read failures surface as an AppFailure, never a raw exception',
      () async {
    // A file path where a directory is expected makes `list()` fail.
    final file = File('${tempDir.path}/blocked');
    await file.writeAsString('x');
    final blocked = ResumeFileStore(root: Directory(file.path));

    expect(
      () => blocked.readAll(),
      throwsA(
        isA<AppFailure>().having(
          (f) => f.kind,
          'kind',
          AppFailureKind.storageRead,
        ),
      ),
    );
  });

  test('a Persian resume keeps its text intact through the file', () async {
    final resume = makeResume('fa').copyWith(
      language: ResumeLanguage.persian,
      professionalSummary: 'خلاصه‌ای کوتاه درباره تجربه و تخصص من.',
    );
    await store.write(resume);

    final restored = await store.read('fa');
    expect(
      restored!.professionalSummary,
      'خلاصه‌ای کوتاه درباره تجربه و تخصص من.',
    );
  });
}
