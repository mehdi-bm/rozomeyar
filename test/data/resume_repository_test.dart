import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/data/local/resume_file_store.dart';
import 'package:resumeyar/data/repositories/resume_repository_impl.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';

void main() {
  late Directory tempDir;
  late ResumeRepositoryImpl repository;

  Resume makeResume(String id, {String? photoPath}) {
    final now = DateTime(2026, 1, 1);
    return Resume(
      id: id,
      title: 'رزومه $id',
      createdAt: now,
      updatedAt: now,
      personalInfo: PersonalInfo(
        firstName: 'مهدی',
        lastName: 'محمدی',
        photoPath: photoPath,
      ),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumeyar_repo_test');
    repository = ResumeRepositoryImpl(
      ResumeFileStore(root: Directory('${tempDir.path}/resumes')),
    );
    await repository.load();
  });

  tearDown(() async {
    await repository.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('save makes the resume immediately readable from the cache', () async {
    await repository.save(makeResume('a'));

    expect(repository.byId('a'), isNotNull);
    expect(repository.all, hasLength(1));
  });

  test('save refreshes updatedAt so the list order stays meaningful', () async {
    final original = makeResume('a');
    await repository.save(original);

    expect(
      repository.byId('a')!.updatedAt.isAfter(original.updatedAt),
      isTrue,
    );
  });

  test('watchAll emits the current list and then every change', () async {
    await repository.save(makeResume('a'));

    final emissions = <int>[];
    final subscription = repository.watchAll().listen(
      (list) => emissions.add(list.length),
    );
    await Future<void>.delayed(Duration.zero);

    await repository.save(makeResume('b'));
    await repository.delete('a');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(emissions, <int>[1, 2, 1]);
  });

  test('data survives a reload from disk', () async {
    await repository.save(makeResume('a'));

    final reloaded = ResumeRepositoryImpl(
      ResumeFileStore(root: Directory('${tempDir.path}/resumes')),
    );
    await reloaded.load();

    expect(reloaded.byId('a')?.title, 'رزومه a');
    await reloaded.dispose();
  });

  group('duplicate', () {
    test('creates an independent copy with a new id and suffixed title',
        () async {
      await repository.save(makeResume('a'));

      final copy = await repository.duplicate('a', copySuffix: 'کپی');

      expect(copy.id, isNot('a'));
      expect(copy.title, 'رزومه a (کپی)');
      expect(repository.all, hasLength(2));
    });

    test('copies content, and editing the copy leaves the original alone',
        () async {
      await repository.save(makeResume('a'));
      final copy = await repository.duplicate('a', copySuffix: 'کپی');

      await repository.save(copy.copyWith(title: 'عوض شد'));

      expect(repository.byId('a')!.title, 'رزومه a');
      expect(repository.byId(copy.id)!.title, 'عوض شد');
    });

    test('throws a StateError for an unknown id', () {
      expect(
        () => repository.duplicate('ghost', copySuffix: 'کپی'),
        throwsStateError,
      );
    });
  });

  group('photo cleanup on delete', () {
    test('removes the photo file when nothing else references it', () async {
      final photo = File('${tempDir.path}/photo.jpg');
      await photo.writeAsBytes(<int>[1, 2, 3]);
      await repository.save(makeResume('a', photoPath: photo.path));

      await repository.delete('a');

      expect(await photo.exists(), isFalse);
    });

    test('keeps the photo while a duplicate still points at it', () async {
      final photo = File('${tempDir.path}/photo.jpg');
      await photo.writeAsBytes(<int>[1, 2, 3]);
      await repository.save(makeResume('a', photoPath: photo.path));
      await repository.duplicate('a', copySuffix: 'کپی');

      await repository.delete('a');

      expect(await photo.exists(), isTrue);
    });

    test('a missing photo file never breaks the delete', () async {
      await repository.save(
        makeResume('a', photoPath: '${tempDir.path}/gone.jpg'),
      );

      await repository.delete('a');

      expect(repository.all, isEmpty);
    });
  });
}
