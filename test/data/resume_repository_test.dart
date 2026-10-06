import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/app_failure.dart';
import 'package:resumeyar/data/local/resume_file_store.dart';
import 'package:resumeyar/data/repositories/resume_repository_impl.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';

import '../support/in_memory_resume_store.dart';

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

    expect(repository.byId('a')!.updatedAt.isAfter(original.updatedAt), isTrue);
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

  test(
    'overlapping saves of one resume all succeed and the last one wins',
    () async {
      final base = makeResume('a');
      // Not awaited individually: these share one temp file on disk, so without
      // serialisation they race and a rename fails or an older copy lands last.
      await Future.wait(<Future<void>>[
        for (var i = 0; i < 10; i++)
          repository.save(base.copyWith(title: 'v$i')),
      ]);

      expect(repository.byId('a')?.title, 'v9');
      final reloaded = ResumeRepositoryImpl(
        ResumeFileStore(root: Directory('${tempDir.path}/resumes')),
      );
      await reloaded.load();
      expect(reloaded.byId('a')?.title, 'v9');
      await reloaded.dispose();
    },
  );

  group('duplicate', () {
    test(
      'creates an independent copy with a new id and suffixed title',
      () async {
        await repository.save(makeResume('a'));

        final copy = await repository.duplicate('a', copySuffix: 'کپی');

        expect(copy.id, isNot('a'));
        expect(copy.title, 'رزومه a (کپی)');
        expect(repository.all, hasLength(2));
      },
    );

    test(
      'copies content, and editing the copy leaves the original alone',
      () async {
        await repository.save(makeResume('a'));
        final copy = await repository.duplicate('a', copySuffix: 'کپی');

        await repository.save(copy.copyWith(title: 'عوض شد'));

        expect(repository.byId('a')!.title, 'رزومه a');
        expect(repository.byId(copy.id)!.title, 'عوض شد');
      },
    );

    test('throws a StateError for an unknown id', () {
      expect(
        () => repository.duplicate('ghost', copySuffix: 'کپی'),
        throwsStateError,
      );
    });
  });

  group('photo cleanup on edit', () {
    test(
      'clearing a photo keeps it until the last duplicate stops using it',
      () async {
        final photo = await File(
          '${tempDir.path}/shared.jpg',
        ).writeAsBytes(<int>[1, 2, 3]);
        await repository.save(makeResume('a', photoPath: photo.path));
        final copy = await repository.duplicate('a', copySuffix: 'کپی');

        final original = repository.byId('a')!;
        await repository.save(
          original.copyWith(
            personalInfo: original.personalInfo.copyWith(clearPhoto: true),
          ),
        );
        expect(await photo.exists(), isTrue);

        await repository.save(
          copy.copyWith(
            personalInfo: copy.personalInfo.copyWith(clearPhoto: true),
          ),
        );
        expect(await photo.exists(), isFalse);
      },
    );

    test('replacing a photo removes only the unused old file', () async {
      final old = await File(
        '${tempDir.path}/old.jpg',
      ).writeAsBytes(<int>[1, 2, 3]);
      final replacement = await File(
        '${tempDir.path}/new.jpg',
      ).writeAsBytes(<int>[4, 5, 6]);
      await repository.save(makeResume('a', photoPath: old.path));

      await repository.save(makeResume('a', photoPath: replacement.path));

      expect(await old.exists(), isFalse);
      expect(await replacement.exists(), isTrue);
    });
  });

  test('a failed delete keeps the resume in the cache and on disk', () async {
    final store = _ControlledStore()..failDelete = true;
    final subject = ResumeRepositoryImpl(store);
    addTearDown(subject.dispose);
    await subject.load();
    await subject.save(makeResume('a'));

    await expectLater(subject.delete('a'), throwsA(isA<AppFailure>()));

    expect(subject.byId('a'), isNotNull);
    expect(await store.read('a'), isNotNull);
  });

  test(
    'deleting during an in-flight save cannot resurrect the resume',
    () async {
      final store = _ControlledStore();
      final subject = ResumeRepositoryImpl(store);
      addTearDown(subject.dispose);
      await subject.load();
      await subject.save(makeResume('a'));

      store.writeStarted = Completer<void>();
      store.releaseWrite = Completer<void>();
      final saving = subject.save(makeResume('a').copyWith(title: 'latest'));
      await store.writeStarted!.future;
      final deleting = subject.delete('a');
      store.releaseWrite!.complete();
      await Future.wait(<Future<void>>[saving, deleting]);

      expect(subject.byId('a'), isNull);
      expect(await store.read('a'), isNull);
    },
  );

  test('a failed save does not block the next operation', () async {
    final store = _ControlledStore()..failWrite = true;
    final subject = ResumeRepositoryImpl(store);
    addTearDown(subject.dispose);
    await subject.load();

    await expectLater(
      subject.save(makeResume('a')),
      throwsA(isA<AppFailure>()),
    );
    store.failWrite = false;
    await subject.save(makeResume('a'));
    expect(subject.byId('a'), isNotNull);
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

class _ControlledStore extends InMemoryResumeStore {
  bool failDelete = false;
  bool failWrite = false;
  Completer<void>? writeStarted;
  Completer<void>? releaseWrite;

  @override
  Future<void> write(Resume resume) async {
    if (failWrite) throw AppFailure(AppFailureKind.storageWrite);
    writeStarted?.complete();
    await releaseWrite?.future;
    await super.write(resume);
  }

  @override
  Future<void> delete(String id) async {
    if (failDelete) throw AppFailure(AppFailureKind.storageWrite);
    await super.delete(id);
  }
}
